// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:notifications_domain/notifications_domain.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ThresholdEvaluator', () {
    const evaluator = ThresholdEvaluator();

    Reading readingAt(double celsius) => Reading(
      roomTemperatureCelsius: celsius,
      roomTemperatureSource: RoomTemperatureSource.sensor,
      outsideTemperatureCelsius: 15,
      timestamp: DateTime(2026),
    );

    const settings = ThresholdSettings(
      minCelsius: 18,
      maxCelsius: 28,
      enabled: true,
    );

    test('returns none when thresholds are disabled', () {
      final disabled = ThresholdSettings(
        minCelsius: 18,
        maxCelsius: 28,
        enabled: false,
      );

      // Would otherwise breach aboveMaximum if enabled.
      final result = evaluator.evaluate(
        reading: readingAt(40),
        settings: disabled,
      );

      expect(result, ThresholdBreach.none);
    });

    test('returns belowMinimum when below the minimum', () {
      final result = evaluator.evaluate(
        reading: readingAt(17.9),
        settings: settings,
      );

      expect(result, ThresholdBreach.belowMinimum);
    });

    test('returns aboveMaximum when above the maximum', () {
      final result = evaluator.evaluate(
        reading: readingAt(28.1),
        settings: settings,
      );

      expect(result, ThresholdBreach.aboveMaximum);
    });

    test('returns none when within range', () {
      final result = evaluator.evaluate(
        reading: readingAt(23),
        settings: settings,
      );

      expect(result, ThresholdBreach.none);
    });

    test('returns none at exact minimum boundary (inclusive)', () {
      final result = evaluator.evaluate(
        reading: readingAt(18),
        settings: settings,
      );

      expect(result, ThresholdBreach.none);
    });

    test('returns none at exact maximum boundary (inclusive)', () {
      final result = evaluator.evaluate(
        reading: readingAt(28),
        settings: settings,
      );

      expect(result, ThresholdBreach.none);
    });
  });
}
