import 'package:history_domain/history_domain.dart';
import 'package:test/test.dart';

void main() {
  group('DailyAverage', () {
    test('normalizes day to midnight UTC', () {
      final average = DailyAverage(
        day: DateTime(2026, 3, 7, 14, 30),
        averageRoomTemperatureCelsius: 22,
        averageOutsideTemperatureCelsius: 18,
        sampleCount: 4,
      );

      expect(average.day, DateTime.utc(2026, 3, 7));
    });

    test('supports value equality', () {
      final a = DailyAverage(
        day: DateTime(2026, 3, 7),
        averageRoomTemperatureCelsius: 22,
        averageOutsideTemperatureCelsius: 18,
        sampleCount: 4,
      );
      final b = DailyAverage(
        day: DateTime(2026, 3, 7),
        averageRoomTemperatureCelsius: 22,
        averageOutsideTemperatureCelsius: 18,
        sampleCount: 4,
      );

      expect(a, b);
    });

    group('isoDateKey', () {
      test('formats a single-digit month and day with zero padding', () {
        final average = DailyAverage(
          day: DateTime(2026, 3, 7),
          averageRoomTemperatureCelsius: 22,
          averageOutsideTemperatureCelsius: 18,
          sampleCount: 1,
        );

        expect(average.isoDateKey, '2026-03-07');
      });

      test('formats a double-digit month and day without extra padding', () {
        final average = DailyAverage(
          day: DateTime(2026, 12, 25),
          averageRoomTemperatureCelsius: 22,
          averageOutsideTemperatureCelsius: 18,
          sampleCount: 1,
        );

        expect(average.isoDateKey, '2026-12-25');
      });
    });
  });
}
