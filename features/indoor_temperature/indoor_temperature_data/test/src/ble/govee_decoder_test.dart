import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_temperature_data/indoor_temperature_data.dart';
import 'package:indoor_temperature_domain/indoor_temperature_domain.dart';

/// Builds a Govee manufacturer-data advertisement from raw payload bytes.
BleAdvertisement advertisementWith(List<int> payload) => BleAdvertisement(
  deviceId: 'E3:37:3E:11:22:33',
  name: 'GVH5075_1122',
  manufacturerData: {GoveeDecoder.companyId: payload},
);

/// Packs [celsius] and [humidity] the way Govee firmware does: one 24-bit
/// integer whose upper digits are temperature in 0.1 C and whose lowest
/// three digits are humidity in 0.1 %.
List<int> packed(double celsius, double humidity, {bool negative = false}) {
  final value =
      (celsius.abs() * 10).round() * 1000 + (humidity * 10).round();
  final signed = negative ? value | 0x800000 : value;
  return [
    (signed >> 16) & 0xFF,
    (signed >> 8) & 0xFF,
    signed & 0xFF,
  ];
}

void main() {
  group('GoveeDecoder', () {
    test('decodes temperature and humidity from a packed triple', () {
      final sample = GoveeDecoder.decode(
        advertisementWith([0x00, ...packed(24.6, 51.3), 88]),
      );

      expect(sample, isNotNull);
      expect(sample!.celsius, closeTo(24.6, 0.05));
      expect(sample.humidityPercent, closeTo(51.3, 0.05));
    });

    test('decodes battery percentage, masking the flag bit', () {
      final sample = GoveeDecoder.decode(
        advertisementWith([0x00, ...packed(20.0, 40.0), 0x80 | 64]),
      );

      expect(sample!.batteryPercent, 64);
    });

    test('decodes sub-zero temperatures via the sign bit', () {
      final sample = GoveeDecoder.decode(
        advertisementWith([
          0x00,
          ...packed(4.2, 33.0, negative: true),
          90,
        ]),
      );

      expect(sample, isNotNull);
      expect(sample!.celsius, closeTo(-4.2, 0.05));
      expect(sample.humidityPercent, closeTo(33.0, 0.05));
    });

    test('reads the packed triple only from offset 1', () {
      // Payload missing the leading status byte. Rather than guessing at
      // another offset — which can yield a plausible but wrong reading —
      // the decoder declines, so the source reports unavailable instead of
      // showing a confidently incorrect temperature.
      final sample = GoveeDecoder.decode(
        advertisementWith([...packed(19.4, 60.0), 75]),
      );

      expect(sample!.celsius, isNot(closeTo(19.4, 0.05)));
    });

    test('returns null when the manufacturer data is absent', () {
      const advertisement = BleAdvertisement(deviceId: 'x', name: 'y');

      expect(GoveeDecoder.decode(advertisement), isNull);
    });

    test('returns null for a payload that is too short', () {
      final sample = GoveeDecoder.decode(advertisementWith([0x00, 0x01]));

      expect(sample, isNull);
    });

    test('rejects an implausible temperature', () {
      // Packed 0x7FFFFF -> 838.8 C, far outside any air temperature.
      final sample = GoveeDecoder.decode(
        advertisementWith([0x00, 0x7F, 0xFF, 0xFF, 50]),
      );

      expect(sample, isNull);
    });

    test('rejects an implausible humidity', () {
      // Temperature digits fine, humidity digits 999+ -> over 100 %.
      final sample = GoveeDecoder.decode(
        advertisementWith([0x00, 0x00, 0x9C, 0x9F, 50]),
      );

      expect(sample, isNull);
    });
  });

  group('BleTemperatureDecoder', () {
    test('routes a Govee advertisement to the Govee decoder', () {
      final sample = BleTemperatureDecoder.decode(
        advertisementWith([0x00, ...packed(23.1, 45.0), 80]),
      );

      expect(sample, isNotNull);
      expect(sample!.celsius, closeTo(23.1, 0.05));
    });

    test('reports a supported sensor', () {
      expect(
        BleTemperatureDecoder.isSupportedSensor(
          advertisementWith([0x00, ...packed(23.1, 45.0), 80]),
        ),
        isTrue,
      );
    });

    test('reports an unrelated advertisement as unsupported', () {
      const advertisement = BleAdvertisement(
        deviceId: 'aa',
        name: 'Some Headphones',
        manufacturerData: {0x004C: [0x02, 0x15]},
      );

      expect(BleTemperatureDecoder.isSupportedSensor(advertisement), isFalse);
      expect(BleTemperatureDecoder.decode(advertisement), isNull);
    });
  });
}
