import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

void main() {
  group('RefreshInterval', () {
    test('default is 15 minutes', () {
      expect(RefreshInterval.defaultInterval, const Duration(minutes: 15));
      expect(
        UserSettings.defaults().refreshInterval,
        const Duration(minutes: 15),
      );
    });

    test('available intervals include 1 minute through 24 hours', () {
      expect(RefreshInterval.available.first, const Duration(minutes: 1));
      expect(RefreshInterval.available.last, const Duration(hours: 24));
      expect(RefreshInterval.available, contains(const Duration(minutes: 5)));
      expect(RefreshInterval.available, contains(const Duration(minutes: 15)));
      expect(RefreshInterval.available, contains(const Duration(hours: 1)));
    });

    test('clamp accepts 1 minute, 5 minutes, 15 minutes, 1 hour, 24 hours', () {
      expect(
        RefreshInterval.clamp(const Duration(minutes: 1)),
        const Duration(minutes: 1),
      );
      expect(
        RefreshInterval.clamp(const Duration(minutes: 5)),
        const Duration(minutes: 5),
      );
      expect(
        RefreshInterval.clamp(const Duration(minutes: 15)),
        const Duration(minutes: 15),
      );
      expect(
        RefreshInterval.clamp(const Duration(hours: 1)),
        const Duration(hours: 1),
      );
      expect(
        RefreshInterval.clamp(const Duration(hours: 24)),
        const Duration(hours: 24),
      );
    });

    test('rejects values below 1 minute', () {
      expect(
        RefreshInterval.clamp(Duration.zero),
        RefreshInterval.defaultInterval,
      );
      expect(
        RefreshInterval.clamp(const Duration(seconds: 30)),
        RefreshInterval.defaultInterval,
      );
    });

    test('rejects values above 24 hours', () {
      expect(
        RefreshInterval.clamp(const Duration(hours: 25)),
        RefreshInterval.defaultInterval,
      );
      expect(
        RefreshInterval.clamp(const Duration(days: 2)),
        RefreshInterval.defaultInterval,
      );
    });

    test('fromMinutes falls back to 15 minutes for invalid storage', () {
      expect(
        RefreshInterval.fromMinutes(null),
        RefreshInterval.defaultInterval,
      );
      expect(RefreshInterval.fromMinutes(0), RefreshInterval.defaultInterval);
      expect(
        RefreshInterval.fromMinutes(60 * 25),
        RefreshInterval.defaultInterval,
      );
      expect(RefreshInterval.fromMinutes(5), const Duration(minutes: 5));
    });

    test('background frequency respects the 15-minute Android floor', () {
      expect(
        RefreshInterval.backgroundFrequency(const Duration(minutes: 1)),
        const Duration(minutes: 15),
      );
      expect(
        RefreshInterval.backgroundFrequency(const Duration(hours: 1)),
        const Duration(hours: 1),
      );
    });

    test('internal sample stays at 2 minutes for long user intervals', () {
      expect(
        RefreshInterval.internalSampleInterval(const Duration(hours: 24)),
        const Duration(minutes: 2),
      );
      expect(
        RefreshInterval.internalSampleInterval(const Duration(minutes: 1)),
        const Duration(minutes: 1),
      );
    });

    test('debugLabel covers minutes and hours', () {
      expect(
        RefreshInterval.debugLabel(const Duration(minutes: 1)),
        '1 minute',
      );
      expect(
        RefreshInterval.debugLabel(const Duration(minutes: 15)),
        '15 minutes',
      );
      expect(RefreshInterval.debugLabel(const Duration(hours: 1)), '1 hour');
      expect(RefreshInterval.debugLabel(const Duration(hours: 24)), '24 hours');
    });
  });
}
