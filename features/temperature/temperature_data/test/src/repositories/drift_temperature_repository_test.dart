import 'package:drift/native.dart';
import 'package:local_database/local_database.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('DriftTemperatureRepository', () {
    late AppDatabase database;
    late DriftTemperatureRepository repository;

    Reading readingAt(DateTime timestamp, {double roomTemperatureC = 22}) =>
        Reading(
          roomTemperatureCelsius: roomTemperatureC,
          roomTemperatureSource: RoomTemperatureSource.ambientSensor,
          outsideTemperatureCelsius: 18,
          timestamp: timestamp,
        );

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = DriftTemperatureRepository(database: database);
    });

    tearDown(() => database.close());

    test('watchLatestReading emits null while nothing is recorded', () {
      expect(repository.watchLatestReading(), emits(isNull));
    });

    test('recordReading round-trips through watchLatestReading', () async {
      final reading = readingAt(DateTime.utc(2026, 3, 7, 9, 30, 15, 250));

      await repository.recordReading(reading: reading);

      expect(await repository.watchLatestReading().first, reading);
    });

    test('a second reading supersedes the first', () async {
      final older = readingAt(
        DateTime.utc(2026, 3, 7, 9),
        roomTemperatureC: 19,
      );
      final newer = readingAt(
        DateTime.utc(2026, 3, 7, 10),
        roomTemperatureC: 24,
      );

      await repository.recordReading(reading: older);
      await repository.recordReading(reading: newer);

      expect(await repository.watchLatestReading().first, newer);
    });

    test('the latest reading is the newest by timestamp, not by '
        'insertion order', () async {
      final newer = readingAt(
        DateTime.utc(2026, 3, 7, 10),
        roomTemperatureC: 24,
      );
      final older = readingAt(
        DateTime.utc(2026, 3, 7, 9),
        roomTemperatureC: 19,
      );

      await repository.recordReading(reading: newer);
      await repository.recordReading(reading: older);

      expect(await repository.watchLatestReading().first, newer);
    });

    test('watchLatestReading emits again when a new reading arrives', () async {
      final first = readingAt(DateTime.utc(2026, 3, 7, 9));
      final second = readingAt(
        DateTime.utc(2026, 3, 7, 10),
        roomTemperatureC: 25,
      );

      final emissions = <Reading?>[];
      final subscription = repository.watchLatestReading().listen(
        emissions.add,
      );
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await repository.recordReading(reading: first);
      await pumpEventQueue();
      await repository.recordReading(reading: second);
      await pumpEventQueue();

      expect(emissions, [null, first, second]);
    });

    test('every reading source survives the round trip', () async {
      for (final source in RoomTemperatureSource.values) {
        final reading = Reading(
          roomTemperatureCelsius: 21,
          roomTemperatureSource: source,
          outsideTemperatureCelsius: 12,
          timestamp: DateTime.utc(2026, 3, 7, source.index),
        );

        await repository.recordReading(reading: reading);

        expect(
          (await repository.watchLatestReading().first)?.roomTemperatureSource,
          source,
        );
      }
    });
  });
}
