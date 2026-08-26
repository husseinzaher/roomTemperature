import 'package:settings_data/settings_data.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

void main() {
  group('UserSettingsConverter', () {
    const converter = UserSettingsConverter();

    group('toMap', () {
      test('produces exactly the local settings fields', () {
        const settings = UserSettings(
          units: Units.fahrenheit,
          threshold: ThresholdSettings(
            minCelsius: 15,
            maxCelsius: 25,
            enabled: true,
          ),
          indoorOffsetCelsius: 1.5,
          indoorTemperaturePreference:
              IndoorTemperaturePreference.batteryTemperature,
          manualIndoorTemperatureCelsius: 22.5,
        );

        final map = converter.toMap(settings);

        expect(
          map,
          {
            'units': 'fahrenheit',
            'thresholdMinC': 15.0,
            'thresholdMaxC': 25.0,
            'thresholdEnabled': true,
            'indoorOffsetC': 1.5,
            'indoorTemperatureSource': 'batteryTemperature',
            'manualIndoorTempC': 22.5,
          },
        );
        expect(map.keys, hasLength(7));
      });

      test('encodes celsius units as "celsius"', () {
        final map = converter.toMap(UserSettings.defaults());
        expect(map['units'], 'celsius');
      });
    });

    group('fromMap', () {
      test('round-trips a fully populated map', () {
        const settings = UserSettings(
          units: Units.fahrenheit,
          threshold: ThresholdSettings(
            minCelsius: 10,
            maxCelsius: 30,
            enabled: true,
          ),
          indoorOffsetCelsius: -2.5,
          indoorTemperaturePreference: IndoorTemperaturePreference.manual,
          manualIndoorTemperatureCelsius: 23,
        );

        expect(converter.fromMap(converter.toMap(settings)), settings);
      });

      test('falls back to defaults for an empty map', () {
        expect(converter.fromMap(const {}), UserSettings.defaults());
      });

      test('falls back field-by-field when only some fields are present', () {
        final result = converter.fromMap(const {'indoorOffsetC': 3.0});
        final defaults = UserSettings.defaults();

        expect(result.units, defaults.units);
        expect(result.threshold, defaults.threshold);
        expect(result.indoorOffsetCelsius, 3.0);
        expect(
          result.indoorTemperaturePreference,
          defaults.indoorTemperaturePreference,
        );
      });

      test('falls back when units is an unrecognized string', () {
        final result = converter.fromMap(const {'units': 'kelvin'});
        expect(result.units, UserSettings.defaults().units);
      });

      test('falls back when units is not a string', () {
        final result = converter.fromMap(const {'units': 42});
        expect(result.units, UserSettings.defaults().units);
      });

      test('falls back when numeric fields are malformed', () {
        final result = converter.fromMap(const {
          'thresholdMinC': 'not-a-number',
          'thresholdMaxC': <String, dynamic>{},
          'indoorOffsetC': null,
        });
        final defaults = UserSettings.defaults();

        expect(result.threshold.minCelsius, defaults.threshold.minCelsius);
        expect(result.threshold.maxCelsius, defaults.threshold.maxCelsius);
        expect(result.indoorOffsetCelsius, defaults.indoorOffsetCelsius);
      });

      test('accepts integer values for numeric fields', () {
        final result = converter.fromMap(const {
          'thresholdMinC': 18,
          'thresholdMaxC': 28,
          'indoorOffsetC': 2,
        });

        expect(result.threshold.minCelsius, 18.0);
        expect(result.threshold.maxCelsius, 28.0);
        expect(result.indoorOffsetCelsius, 2.0);
      });

      test('falls back when thresholdEnabled is not a bool', () {
        final result = converter.fromMap(const {'thresholdEnabled': 'true'});
        expect(
          result.threshold.enabled,
          UserSettings.defaults().threshold.enabled,
        );
      });

      test('falls back when indoor source is an unrecognized string', () {
        final result = converter.fromMap(
          const {'indoorTemperatureSource': 'phoneGuess'},
        );

        expect(
          result.indoorTemperaturePreference,
          IndoorTemperaturePreference.automatic,
        );
      });

      test('accepts integer manual temperature values', () {
        final result = converter.fromMap(const {'manualIndoorTempC': 21});

        expect(result.manualIndoorTemperatureCelsius, 21.0);
      });
    });
  });
}
