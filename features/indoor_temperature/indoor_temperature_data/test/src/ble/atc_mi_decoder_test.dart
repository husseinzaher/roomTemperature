import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_temperature_data/indoor_temperature_data.dart';
import 'package:indoor_temperature_domain/indoor_temperature_domain.dart';

/// Builds a 0x181A service-data advertisement from raw payload bytes.
BleAdvertisement advertisementWith(List<int> payload) => BleAdvertisement(
  deviceId: 'A4:C1:38:11:22:33',
  name: 'ATC_112233',
  serviceData: {AtcMiDecoder.serviceUuid: payload},
);

const _mac = [0xA4, 0xC1, 0x38, 0x11, 0x22, 0x33];

void main() {
  group('AtcMiDecoder', () {
    group('pvvx custom format (15 bytes)', () {
      // 22.51 C -> 2251 -> 0x08CB, little-endian: CB 08
      // 48.25 % -> 4825 -> 0x12D9, little-endian: D9 12
      List<int> pvvxPayload({
        List<int> temp = const [0xCB, 0x08],
        List<int> humidity = const [0xD9, 0x12],
        int batteryPercent = 87,
      }) => [
        ..._mac,
        ...temp,
        ...humidity,
        0x0C,
        0x0B, // battery mV
        batteryPercent,
        0x05, // counter
        0x00, // flags
      ];

      test('decodes temperature at 0.01 C resolution', () {
        final sample = AtcMiDecoder.decode(
          advertisementWith(pvvxPayload()),
        );

        expect(sample, isNotNull);
        expect(sample!.celsius, closeTo(22.51, 0.001));
      });

      test('decodes humidity at 0.01 % resolution', () {
        final sample = AtcMiDecoder.decode(advertisementWith(pvvxPayload()));

        expect(sample!.humidityPercent, closeTo(48.25, 0.001));
      });

      test('decodes battery percentage', () {
        final sample = AtcMiDecoder.decode(advertisementWith(pvvxPayload()));

        expect(sample!.batteryPercent, 87);
      });

      test('decodes sub-zero temperatures', () {
        // -5.30 C -> -530 -> 0xFDEE two's complement, little-endian: EE FD
        final sample = AtcMiDecoder.decode(
          advertisementWith(pvvxPayload(temp: [0xEE, 0xFD])),
        );

        expect(sample!.celsius, closeTo(-5.30, 0.001));
      });

      test('rejects an implausible temperature', () {
        // 0x7FFF -> 327.67 C
        final sample = AtcMiDecoder.decode(
          advertisementWith(pvvxPayload(temp: [0xFF, 0x7F])),
        );

        expect(sample, isNull);
      });

      test('drops an out-of-range battery percentage', () {
        final sample = AtcMiDecoder.decode(
          advertisementWith(pvvxPayload(batteryPercent: 200)),
        );

        expect(sample!.batteryPercent, isNull);
      });
    });

    group('atc1441 format (13 bytes)', () {
      // 21.5 C -> 215 -> 0x00D7, little-endian: D7 00
      List<int> atcPayload({
        List<int> temp = const [0xD7, 0x00],
        int humidity = 44,
        int batteryPercent = 91,
      }) => [
        ..._mac,
        ...temp,
        humidity,
        batteryPercent,
        0x0C,
        0x0B, // battery mV
        0x07, // counter
      ];

      test('decodes temperature at 0.1 C resolution', () {
        final sample = AtcMiDecoder.decode(advertisementWith(atcPayload()));

        expect(sample, isNotNull);
        expect(sample!.celsius, closeTo(21.5, 0.001));
      });

      test('decodes humidity and battery', () {
        final sample = AtcMiDecoder.decode(advertisementWith(atcPayload()));

        expect(sample!.humidityPercent, 44);
        expect(sample.batteryPercent, 91);
      });

      test('falls back to big-endian when little-endian is implausible', () {
        // Big-endian 0x00D7 = 215 -> 21.5 C. Read little-endian those same
        // bytes are 0xD700 = -10496 -> -1049.6 C, which is rejected, so the
        // decoder must retry as big-endian.
        final sample = AtcMiDecoder.decode(
          advertisementWith(atcPayload(temp: [0x00, 0xD7])),
        );

        expect(sample, isNotNull);
        expect(sample!.celsius, closeTo(21.5, 0.001));
      });

      test('decodes sub-zero temperatures', () {
        // -3.2 C -> -32 -> 0xFFE0, little-endian: E0 FF
        final sample = AtcMiDecoder.decode(
          advertisementWith(atcPayload(temp: [0xE0, 0xFF])),
        );

        expect(sample!.celsius, closeTo(-3.2, 0.001));
      });
    });

    test('returns null when the service data is absent', () {
      const advertisement = BleAdvertisement(deviceId: 'x', name: 'y');

      expect(AtcMiDecoder.decode(advertisement), isNull);
    });

    test('returns null for an unrecognised payload length', () {
      final sample = AtcMiDecoder.decode(
        advertisementWith(List<int>.filled(9, 0)),
      );

      expect(sample, isNull);
    });
  });
}
