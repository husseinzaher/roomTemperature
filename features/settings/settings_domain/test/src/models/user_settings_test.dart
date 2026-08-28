import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

void main() {
  group('UserSettings', () {
    test('defaults are Celsius, an 18-28°C disabled threshold, no offset', () {
      final defaults = UserSettings.defaults();

      expect(defaults.units, Units.celsius);
      expect(defaults.threshold.minCelsius, 18);
      expect(defaults.threshold.maxCelsius, 28);
      expect(defaults.threshold.enabled, isFalse);
      expect(defaults.indoorOffsetCelsius, 0.0);
      expect(
        defaults.indoorTemperaturePreference,
        IndoorTemperaturePreference.automatic,
      );
      expect(defaults.manualIndoorTemperatureCelsius, isNull);
      expect(defaults.refreshInterval, const Duration(minutes: 15));
      expect(defaults.placeHistoryEnabled, isTrue);
    });

    test('supports value equality', () {
      expect(UserSettings.defaults(), equals(UserSettings.defaults()));
    });

    test('differs when any field differs', () {
      final defaults = UserSettings.defaults();

      expect(
        defaults,
        isNot(equals(defaults.copyWith(units: Units.fahrenheit))),
      );
      expect(
        defaults,
        isNot(equals(defaults.copyWith(indoorOffsetCelsius: 1.5))),
      );
      expect(
        defaults,
        isNot(
          equals(
            defaults.copyWith(
              indoorTemperaturePreference:
                  IndoorTemperaturePreference.batteryTemperature,
            ),
          ),
        ),
      );
      expect(
        defaults,
        isNot(
          equals(
            defaults.copyWith(
              threshold: defaults.threshold.copyWith(enabled: true),
            ),
          ),
        ),
      );
    });

    test('copyWith replaces only the given fields', () {
      final defaults = UserSettings.defaults();
      final updated = defaults.copyWith(indoorOffsetCelsius: 2.5);

      expect(updated.indoorOffsetCelsius, 2.5);
      expect(updated.units, defaults.units);
      expect(updated.threshold, defaults.threshold);
      expect(
        updated.indoorTemperaturePreference,
        defaults.indoorTemperaturePreference,
      );
      expect(updated.refreshInterval, defaults.refreshInterval);
    });

    test('copyWith replaces the refresh interval', () {
      final updated = UserSettings.defaults().copyWith(
        refreshInterval: const Duration(minutes: 5),
      );
      expect(updated.refreshInterval, const Duration(minutes: 5));
    });
  });
}
