import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:history_data/history_data.dart';
import 'package:test/test.dart';

void main() {
  group('DailyAverageConverter', () {
    const converter = DailyAverageConverter();

    group('fromFirestore', () {
      test('computes averages from stored sums and sample count', () {
        final data = {
          'day': Timestamp.fromDate(DateTime.utc(2026, 3, 7)),
          'sumRoomTempC': 88.0,
          'sumOutsideTempC': 72.0,
          'sampleCount': 4,
        };

        final result = converter.fromFirestore('2026-03-07', data);

        expect(result.day, DateTime.utc(2026, 3, 7));
        expect(result.averageRoomTemperatureCelsius, 22);
        expect(result.averageOutsideTemperatureCelsius, 18);
        expect(result.sampleCount, 4);
      });

      test('handles a single sample (sum equals the raw value)', () {
        final data = {
          'day': Timestamp.fromDate(DateTime.utc(2026, 3, 7)),
          'sumRoomTempC': 22.5,
          'sumOutsideTempC': 18.5,
          'sampleCount': 1,
        };

        final result = converter.fromFirestore('2026-03-07', data);

        expect(result.averageRoomTemperatureCelsius, 22.5);
        expect(result.averageOutsideTemperatureCelsius, 18.5);
      });

      test('falls back to parsing the day from docId when the day field '
          'is missing', () {
        final data = {
          'sumRoomTempC': 44.0,
          'sumOutsideTempC': 36.0,
          'sampleCount': 2,
        };

        final result = converter.fromFirestore('2026-12-25', data);

        expect(result.day, DateTime.utc(2026, 12, 25));
        expect(result.averageRoomTemperatureCelsius, 22);
        expect(result.averageOutsideTemperatureCelsius, 18);
      });
    });

    group('toFirestoreUpdate', () {
      test('returns FieldValue.increment entries for sums and count', () {
        final update = converter.toFirestoreUpdate(
          addRoomTempC: 22.5,
          addOutsideTempC: 18.5,
        );

        expect(
          update['sumRoomTempC'],
          FieldValue.increment(22.5),
        );
        expect(
          update['sumOutsideTempC'],
          FieldValue.increment(18.5),
        );
        expect(update['sampleCount'], FieldValue.increment(1));
      });

      test('map only contains the sum and count keys (no day field)', () {
        final update = converter.toFirestoreUpdate(
          addRoomTempC: 1,
          addOutsideTempC: 2,
        );

        expect(
          update.keys,
          containsAll(['sumRoomTempC', 'sumOutsideTempC', 'sampleCount']),
        );
        expect(update.containsKey('day'), isFalse);
      });
    });
  });
}
