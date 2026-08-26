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
    if (celsius != null) yield celsius!;
  }
}

void main() {
  const weather = OutsideWeather(
    temperatureCelsius: 20,
    condition: WeatherCondition.clear,
    isDay: true,
    apparentTemperatureCelsius: 19,
    relativeHumidityPercent: 40,
    windSpeedKph: 10,
    surfacePressureHpa: 1010,
    uvIndex: 3,
  );

  IndoorTemperatureService buildService({
    IndoorTemperatureProvider? ambient,
    IndoorTemperatureProvider? bluetooth,
    IndoorTemperatureProvider? battery,
    IndoorTemperatureProvider? manual,
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
      );

      final reading = await service.resolve(
        preference: IndoorTemperaturePreference.automatic,
        weather: weather,
        indoorOffsetCelsius: 0,
      );

      expect(reading?.celsius, 21.4);
      expect(reading?.source, IndoorTemperatureSource.ambientSensor);
    });

    test(
      'automatic falls through to battery when ambient and bluetooth are gone',
      () async {
        final service = buildService(
          battery: _FakeProvider(
            source: IndoorTemperatureSource.batteryTemperature,
            available: true,
            celsius: 36.5,
          ),
        );

        final reading = await service.resolve(
          preference: IndoorTemperaturePreference.automatic,
          weather: weather,
          indoorOffsetCelsius: 2,
        );

        expect(reading?.celsius, 36.5);
        expect(reading?.source, IndoorTemperatureSource.batteryTemperature);
      },
    );

    test('automatic uses the weather estimate as the last fallback', () async {
      final service = buildService();

      final reading = await service.resolve(
        preference: IndoorTemperaturePreference.automatic,
        weather: weather,
        indoorOffsetCelsius: 1.5,
      );

      expect(reading?.celsius, 21.5);
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
          weather: weather,
          indoorOffsetCelsius: 0,
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
          weather: weather,
          indoorOffsetCelsius: 0,
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
