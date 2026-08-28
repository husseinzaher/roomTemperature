import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/services/indoor_temperature_service.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';

class _FakeProvider implements IndoorTemperatureProvider {
  _FakeProvider({
    required this.source,
    this.available = false,
    this.celsius,
  });

  @override
  final IndoorTemperatureSource source;
  final bool available;
  final double? celsius;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Stream<double> get temperatureStream async* {
    if (celsius != null) {
      yield celsius!;
    }
  }
}

void main() {
  IndoorTemperatureService buildService({
    IndoorTemperatureProvider? ambient,
    IndoorTemperatureProvider? bluetooth,
    IndoorTemperatureProvider? battery,
    IndoorTemperatureProvider? manual,
    IndoorTemperatureProvider? thermal,
  }) {
    return IndoorTemperatureService(
      ambientProvider:
          ambient ??
          _FakeProvider(source: IndoorTemperatureSource.ambientSensor),
      bluetoothProvider:
          bluetooth ??
          _FakeProvider(source: IndoorTemperatureSource.bluetoothSensor),
      batteryProvider:
          battery ??
          _FakeProvider(source: IndoorTemperatureSource.batteryTemperature),
      manualProvider:
          manual ?? _FakeProvider(source: IndoorTemperatureSource.manual),
      thermalProvider:
          thermal ?? _FakeProvider(source: IndoorTemperatureSource.estimated),
    );
  }

  group('IndoorTemperatureService', () {
    test('automatic uses ambient sensor when it is available', () async {
      final service = buildService(
        ambient: _FakeProvider(
          source: IndoorTemperatureSource.ambientSensor,
          available: true,
          celsius: 21.4,
        ),
        battery: _FakeProvider(
          source: IndoorTemperatureSource.batteryTemperature,
          available: true,
          celsius: 36.5,
        ),
        thermal: _FakeProvider(
          source: IndoorTemperatureSource.estimated,
          available: true,
          celsius: 26,
        ),
      );

      final reading = await service.resolve(
        preference: IndoorTemperaturePreference.automatic,
      );

      expect(reading?.celsius, 21.4);
      expect(reading?.source, IndoorTemperatureSource.ambientSensor);
    });

    test(
      'automatic uses local thermal estimate instead of battery',
      () async {
        final service = buildService(
          battery: _FakeProvider(
            source: IndoorTemperatureSource.batteryTemperature,
            available: true,
            celsius: 36.5,
          ),
          thermal: _FakeProvider(
            source: IndoorTemperatureSource.estimated,
            available: true,
            celsius: 24.7,
          ),
        );

        final reading = await service.resolve(
          preference: IndoorTemperaturePreference.automatic,
        );

        expect(reading?.celsius, 24.7);
        expect(reading?.source, IndoorTemperatureSource.estimated);
      },
    );

    test('automatic does not require weather or an offset', () async {
      final service = buildService(
        thermal: _FakeProvider(
          source: IndoorTemperatureSource.estimated,
          available: true,
          celsius: 25,
        ),
      );

      final reading = await service.resolve(
        preference: IndoorTemperaturePreference.automatic,
      );

      expect(reading?.celsius, 25);
      expect(reading?.source, IndoorTemperatureSource.estimated);
    });

    test(
      'explicit battery selection is allowed and labelled as battery',
      () async {
        final service = buildService(
          battery: _FakeProvider(
            source: IndoorTemperatureSource.batteryTemperature,
            available: true,
            celsius: 36.5,
          ),
        );

        final reading = await service.resolve(
          preference: IndoorTemperaturePreference.batteryTemperature,
        );

        expect(reading?.celsius, 36.5);
        expect(reading?.source, IndoorTemperatureSource.batteryTemperature);
      },
    );

    test(
      'explicit selection returns null when that source is unavailable',
      () async {
        final service = buildService();

        final reading = await service.resolve(
          preference: IndoorTemperaturePreference.ambientSensor,
        );

        expect(reading, isNull);
      },
    );

    test('availability reports each source independently', () async {
      final service = buildService(
        ambient: _FakeProvider(
          source: IndoorTemperatureSource.ambientSensor,
          available: true,
          celsius: 22,
        ),
        battery: _FakeProvider(
          source: IndoorTemperatureSource.batteryTemperature,
          available: true,
          celsius: 36.5,
        ),
      );

      final availability = await service.availability();

      expect(availability[IndoorTemperatureSource.ambientSensor], isTrue);
      expect(availability[IndoorTemperatureSource.bluetoothSensor], isFalse);
      expect(availability[IndoorTemperatureSource.batteryTemperature], isTrue);
      expect(availability[IndoorTemperatureSource.estimated], isTrue);
    });
  });
}
