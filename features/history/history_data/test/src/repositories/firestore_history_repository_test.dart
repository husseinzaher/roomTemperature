import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:history_data/history_data.dart';
import 'package:test/test.dart';

void main() {
  group('FirestoreHistoryRepository', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreHistoryRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = FirestoreHistoryRepository(firestore: firestore);
    });

    group('recordSample', () {
      test('creates a doc with sum=value, count=1 on first sample', () async {
        final day = DateTime(2026, 3, 7);

        await repository.recordSample(
          userId: 'user-1',
          day: day,
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        );

        final doc = await firestore
            .collection('users')
            .doc('user-1')
            .collection('dailyAverages')
            .doc('2026-03-07')
            .get();

        expect(doc.exists, isTrue);
        expect(doc.data()!['sumRoomTempC'], 22);
        expect(doc.data()!['sumOutsideTempC'], 18);
        expect(doc.data()!['sampleCount'], 1);
      });

      test('increments sums/count on a second sample of same day', () async {
        final day = DateTime(2026, 3, 7);

        await repository.recordSample(
          userId: 'user-1',
          day: day,
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        );
        await repository.recordSample(
          userId: 'user-1',
          day: day,
          roomTemperatureCelsius: 24,
          outsideTemperatureCelsius: 20,
        );

        final doc = await firestore
            .collection('users')
            .doc('user-1')
            .collection('dailyAverages')
            .doc('2026-03-07')
            .get();

        expect(doc.data()!['sumRoomTempC'], 46);
        expect(doc.data()!['sumOutsideTempC'], 38);
        expect(doc.data()!['sampleCount'], 2);
      });

      test('keeps separate documents for different days', () async {
        await repository.recordSample(
          userId: 'user-1',
          day: DateTime(2026, 3, 6),
          roomTemperatureCelsius: 20,
          outsideTemperatureCelsius: 15,
        );
        await repository.recordSample(
          userId: 'user-1',
          day: DateTime(2026, 3, 7),
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        );

        final collection = firestore
            .collection('users')
            .doc('user-1')
            .collection('dailyAverages');
        final snapshot = await collection.get();

        expect(snapshot.docs, hasLength(2));
      });
    });

    group('watchHistory', () {
      test('emits DailyAverages ordered most-recent-first', () async {
        await repository.recordSample(
          userId: 'user-1',
          day: DateTime(2026, 3, 6),
          roomTemperatureCelsius: 20,
          outsideTemperatureCelsius: 15,
        );
        await repository.recordSample(
          userId: 'user-1',
          day: DateTime(2026, 3, 7),
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        );

        final history = await repository.watchHistory(userId: 'user-1').first;

        expect(history, hasLength(2));
        expect(history.first.day, DateTime.utc(2026, 3, 7));
        expect(history.last.day, DateTime.utc(2026, 3, 6));
      });

      test('respects the days limit', () async {
        await repository.recordSample(
          userId: 'user-1',
          day: DateTime(2026, 3, 5),
          roomTemperatureCelsius: 19,
          outsideTemperatureCelsius: 14,
        );
        await repository.recordSample(
          userId: 'user-1',
          day: DateTime(2026, 3, 6),
          roomTemperatureCelsius: 20,
          outsideTemperatureCelsius: 15,
        );
        await repository.recordSample(
          userId: 'user-1',
          day: DateTime(2026, 3, 7),
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        );

        final history = await repository
            .watchHistory(userId: 'user-1', days: 2)
            .first;

        expect(history, hasLength(2));
      });

      test('emits an empty list when there is no history yet', () async {
        final history = await repository.watchHistory(userId: 'user-1').first;

        expect(history, isEmpty);
      });
    });
  });
}
