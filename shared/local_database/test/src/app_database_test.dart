import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_database/local_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase(NativeDatabase.memory()));
    tearDown(() => database.close());

    test('schemaVersion is 1', () {
      expect(database.schemaVersion, 1);
    });

    test('normalizeDay strips the time component to midnight UTC', () {
      expect(
        AppDatabase.normalizeDay(DateTime.utc(2026, 8, 26, 17, 45, 3)),
        DateTime.utc(2026, 8, 26),
      );
    });

    test('insertReading appends a row watchLatestReading emits', () async {
      final recordedAt = DateTime.utc(2026, 8, 26, 12, 30, 15, 250);
      await database.insertReading(
        roomTemperatureC: 21.5,
        roomTemperatureSource: 'estimated',
        outsideTemperatureC: 30.25,
        recordedAt: recordedAt,
      );

      final row = await database.watchLatestReading().first;

      expect(row, isNotNull);
      expect(row!.roomTemperatureC, 21.5);
      expect(row.roomTemperatureSource, 'estimated');
      expect(row.outsideTemperatureC, 30.25);
      // Sub-second precision survives the round trip.
      expect(row.recordedAt.toUtc(), recordedAt);
    });

    test('watchLatestReading emits null while empty', () async {
      expect(await database.watchLatestReading().first, isNull);
    });

    test('recordDailySample creates then increments a day row', () async {
      final day = DateTime.utc(2026, 8, 26);
      await database.recordDailySample(
        day: day,
        roomTemperatureC: 20,
        outsideTemperatureC: 30,
      );
      await database.recordDailySample(
        day: DateTime.utc(2026, 8, 26, 23, 59),
        roomTemperatureC: 22,
        outsideTemperatureC: 34,
      );

      final rows = await database.watchRecentDailyAverages().first;

      expect(rows, hasLength(1));
      expect(rows.single.day.toUtc(), day);
      expect(rows.single.sumRoomTempC, 42);
      expect(rows.single.sumOutsideTempC, 64);
      expect(rows.single.sampleCount, 2);
    });

    test('watchRecentDailyAverages is most-recent-first and honours '
        'limit', () async {
      for (var dayOfMonth = 1; dayOfMonth <= 3; dayOfMonth++) {
        await database.recordDailySample(
          day: DateTime.utc(2026, 8, dayOfMonth),
          roomTemperatureC: 20,
          outsideTemperatureC: 30,
        );
      }

      final rows = await database.watchRecentDailyAverages(limit: 2).first;

      expect(
        rows.map((row) => row.day.toUtc()),
        [DateTime.utc(2026, 8, 3), DateTime.utc(2026, 8, 2)],
      );
    });

    test('settings round-trip through the generic key/value API', () async {
      expect(await database.readSetting('units'), isNull);

      await database.writeSetting('units', 'fahrenheit');
      expect(await database.readSetting('units'), 'fahrenheit');

      await database.writeSetting('units', 'celsius');
      expect(await database.readSetting('units'), 'celsius');

      await database.writeSettings({'a': '1', 'b': '2'});
      expect(await database.readSettings(), {
        'units': 'celsius',
        'a': '1',
        'b': '2',
      });
    });

    test('watchSetting emits null then the written value', () async {
      final emissions = <String?>[];
      final subscription = database
          .watchSetting('indoorSource')
          .listen(emissions.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await database.writeSetting('indoorSource', 'ambientSensor');
      await pumpEventQueue();

      expect(emissions, [null, 'ambientSensor']);
    });

    test('watchSettings emits the full map on every change', () async {
      final emissions = <Map<String, String>>[];
      final subscription = database.watchSettings().listen(emissions.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await database.writeSetting('units', 'celsius');
      await pumpEventQueue();

      expect(emissions, [
        <String, String>{},
        {'units': 'celsius'},
      ]);
    });
  });
}
