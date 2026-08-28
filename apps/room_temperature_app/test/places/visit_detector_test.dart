import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/places/visit_detector.dart';
import 'package:room_temperature_app/places/visit_rules.dart';

void main() {
  const detector = VisitDetector();
  final origin = DateTime.utc(2026, 8, 28, 12);

  LocationFix fix({
    required DateTime at,
    double lat = 30.0,
    double lng = 31.0,
    double? indoor = 24,
  }) {
    return LocationFix(
      latitude: lat,
      longitude: lng,
      at: at,
      indoorCelsius: indoor,
    );
  }

  group('VisitRules', () {
    test('rejects invalid indoor samples', () {
      expect(VisitRules.isValidIndoorCelsius(null), isFalse);
      expect(VisitRules.isValidIndoorCelsius(double.nan), isFalse);
      expect(VisitRules.isValidIndoorCelsius(4.9), isFalse);
      expect(VisitRules.isValidIndoorCelsius(45.1), isFalse);
      expect(VisitRules.isValidIndoorCelsius(24.1), isTrue);
    });
  });

  group('VisitDetector', () {
    test('groups samples within 100m into one visit', () {
      var tick = detector.observe(current: null, fix: fix(at: origin));
      tick = detector.observe(
        current: tick.open,
        fix: fix(
          at: origin.add(const Duration(minutes: 15)),
          lat: 30.0005,
          indoor: 24.2,
        ),
      );

      expect(tick.completed, isNull);
      expect(tick.open, isNotNull);
      expect(tick.open!.stats.count, 2);
      expect(tick.open!.stats.average, closeTo(24.1, 0.0001));
    });

    test('does not complete a stay shorter than 30 minutes', () {
      var tick = detector.observe(current: null, fix: fix(at: origin));
      tick = detector.observe(
        current: tick.open,
        fix: fix(
          at: origin.add(const Duration(minutes: 20)),
          indoor: 24.1,
        ),
      );
      tick = detector.observe(
        current: tick.open,
        fix: fix(
          at: origin.add(const Duration(minutes: 21)),
          lat: 30.02,
          lng: 31.02,
        ),
      );

      expect(tick.completed, isNull);
      expect(tick.discardedShortStay, isTrue);
      expect(tick.open, isNotNull);
    });

    test('completes a visit after min dwell and a location change', () {
      var tick = detector.observe(current: null, fix: fix(at: origin));
      tick = detector.observe(
        current: tick.open,
        fix: fix(
          at: origin.add(const Duration(minutes: 30)),
          indoor: 24.4,
        ),
      );
      tick = detector.observe(
        current: tick.open,
        fix: fix(
          at: origin.add(const Duration(minutes: 31)),
          lat: 31,
          lng: 32,
          indoor: 23,
        ),
      );

      expect(tick.completed, isNotNull);
      expect(tick.completed!.stats.count, 2);
      expect(tick.completed!.stats.average, closeTo(24.2, 0.0001));
      expect(
        tick.completed!.duration,
        const Duration(minutes: 30),
      );
      expect(tick.open!.latitude, 31);
    });

    test('ignores invalid indoor samples in the average', () {
      var tick = detector.observe(
        current: null,
        fix: fix(at: origin, indoor: 80),
      );
      tick = detector.observe(
        current: tick.open,
        fix: fix(at: origin.add(const Duration(minutes: 15))),
      );

      expect(tick.open!.stats.count, 1);
      expect(tick.open!.stats.average, 24);
    });
  });

  group('IndoorSampleStats', () {
    test('averages min and max from valid samples', () {
      final stats = IndoorSampleStats.empty
          .add(24)
          .add(24.2)
          .add(24.1)
          .add(24);
      expect(stats.count, 4);
      expect(stats.average, closeTo(24.075, 0.0001));
      expect(stats.min, 24);
      expect(stats.max, 24.2);
    });
  });
}
