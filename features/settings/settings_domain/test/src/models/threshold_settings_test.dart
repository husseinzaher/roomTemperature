import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ThresholdSettings', () {
    const settings = ThresholdSettings(
      minCelsius: 18,
      maxCelsius: 28,
      enabled: true,
    );

    test('supports value equality', () {
      expect(
        settings,
        equals(
          const ThresholdSettings(
            minCelsius: 18,
            maxCelsius: 28,
            enabled: true,
          ),
        ),
      );
    });

    test('differs when any field differs', () {
      expect(settings, isNot(equals(settings.copyWith(minCelsius: 17))));
      expect(settings, isNot(equals(settings.copyWith(maxCelsius: 29))));
      expect(settings, isNot(equals(settings.copyWith(enabled: false))));
    });

    test('copyWith replaces only the given fields', () {
      final updated = settings.copyWith(minCelsius: 15);

      expect(updated.minCelsius, 15);
      expect(updated.maxCelsius, settings.maxCelsius);
      expect(updated.enabled, settings.enabled);
    });

    test('copyWith with no arguments returns an equal copy', () {
      expect(settings.copyWith(), equals(settings));
    });
  });
}
