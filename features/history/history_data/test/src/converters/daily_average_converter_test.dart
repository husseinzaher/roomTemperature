import 'package:history_data/history_data.dart';
import 'package:test/test.dart';

void main() {
  group('DailyAverageConverter', () {
    const converter = DailyAverageConverter();

    group('fromMap', () {
      test('computes averages from stored sums and sample count', () {
        final data = {
          'sumRoomTempC': 88.0,
          'sumOutsideTempC': 72.0,
          'sampleCount': 4,
        };

        final result = converter.fromMap('2026-03-07', data);

        expect(result.day, DateTime.utc(2026, 3, 7));
        expect(result.averageRoomTemperatureCelsius, 22);
        expect(result.averageOutsideTemperatureCelsius, 18);
        expect(result.sampleCount, 4);
      });

      test('handles a single sample (sum equals the raw value)', () {
        final data = {
          'sumRoomTempC': 22.5,
          'sumOutsideTempC': 18.5,
          'sampleCount': 1,
        };

        final result = converter.fromMap('2026-03-07', data);

        expect(result.averageRoomTemperatureCelsius, 22.5);
        expect(result.averageOutsideTemperatureCelsius, 18.5);
      });

      test('parses the day from docId', () {
        final data = {
          'sumRoomTempC': 44.0,
          'sumOutsideTempC': 36.0,
          'sampleCount': 2,
        };

        final result = converter.fromMap('2026-12-25', data);

        expect(result.day, DateTime.utc(2026, 12, 25));
        expect(result.averageRoomTemperatureCelsius, 22);
        expect(result.averageOutsideTemperatureCelsius, 18);
      });
    });

    group('addSample', () {
      test('adds a new sample to empty sums', () {
        final update = converter.addSample(
          current: null,
          addRoomTempC: 22.5,
          addOutsideTempC: 18.5,
        );

        expect(update['sumRoomTempC'], 22.5);
        expect(update['sumOutsideTempC'], 18.5);
        expect(update['sampleCount'], 1);
      });

      test('map only contains the sum and count keys (no day field)', () {
        final update = converter.addSample(
          current: const {
            'sumRoomTempC': 1.0,
            'sumOutsideTempC': 2.0,
            'sampleCount': 3,
          },
          addRoomTempC: 1,
          addOutsideTempC: 2,
        );

        expect(update['sumRoomTempC'], 2.0);
        expect(update['sumOutsideTempC'], 4.0);
        expect(update['sampleCount'], 4);
        expect(
          update.keys,
          containsAll(['sumRoomTempC', 'sumOutsideTempC', 'sampleCount']),
        );
        expect(update.containsKey('day'), isFalse);
      });
    });
  });
}
