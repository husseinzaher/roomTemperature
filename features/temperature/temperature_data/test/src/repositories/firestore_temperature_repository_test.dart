import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('FirestoreTemperatureRepository', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreTemperatureRepository repository;

    const userId = 'user-1';
    final reading = Reading(
      roomTemperatureCelsius: 24,
      roomTemperatureSource: RoomTemperatureSource.estimated,
      outsideTemperatureCelsius: 20,
      timestamp: DateTime.utc(2026),
    );

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = FirestoreTemperatureRepository(firestore: firestore);
    });

    test(
      'recordReading adds the converted reading to the readings collection',
      () async {
        await repository.recordReading(userId: userId, reading: reading);

        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('readings')
            .get();

        expect(snapshot.docs, hasLength(1));
        final written = snapshot.docs.single.data();
        expect(written['roomTemperatureC'], 24);
        expect(written['roomTemperatureSource'], 'estimated');
        expect(written['outsideTemperatureC'], 20);
      },
    );

    test('watchLatestReading emits null when there are no readings', () {
      expect(
        repository.watchLatestReading(userId: userId),
        emits(null),
      );
    });

    test('watchLatestReading emits the converted latest reading', () async {
      await repository.recordReading(userId: userId, reading: reading);

      final olderReading = Reading(
        roomTemperatureCelsius: 18,
        roomTemperatureSource: RoomTemperatureSource.sensor,
        outsideTemperatureCelsius: 12,
        timestamp: DateTime.utc(2025, 12, 31),
      );
      await repository.recordReading(userId: userId, reading: olderReading);

      final latest = await repository.watchLatestReading(userId: userId).first;

      // Compared field-by-field rather than via Reading's equality: Firestore
      // Timestamps don't preserve the UTC/local flag on their round trip, so
      // the returned timestamp is the same instant as `reading.timestamp`
      // but may come back with a different `isUtc` value, which Dart's
      // `DateTime.==` treats as unequal.
      expect(latest, isNotNull);
      expect(latest!.roomTemperatureCelsius, reading.roomTemperatureCelsius);
      expect(latest.roomTemperatureSource, reading.roomTemperatureSource);
      expect(
        latest.outsideTemperatureCelsius,
        reading.outsideTemperatureCelsius,
      );
      expect(latest.timestamp.isAtSameMomentAs(reading.timestamp), isTrue);
    });
  });
}
