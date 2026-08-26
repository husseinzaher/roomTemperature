import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:local_database/src/tables/daily_averages.dart';
import 'package:local_database/src/tables/readings.dart';
import 'package:local_database/src/tables/settings_rows.dart';

part 'app_database.g.dart';

/// {@template app_database}
/// The on-device SQLite database, and the only place this app stores data.
///
/// Everything the app persists lives here: the append-only [Readings] time
/// series, the per-day running sums in [DailyAverages], and the generic
/// key/value [SettingsRows]. There is no account and no remote backend, so
/// there is no user id anywhere in this schema — a device has exactly one
/// database.
///
/// Construct it without arguments to open the real file in the app's
/// documents directory, or pass a [QueryExecutor] (typically
/// `NativeDatabase.memory()`) to run against a throwaway database in tests.
/// {@endtemplate}
@DriftDatabase(tables: [Readings, DailyAverages, SettingsRows])
class AppDatabase extends _$AppDatabase {
  /// {@macro app_database}
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: databaseName));

  /// The file name (without extension) of the on-device database.
  static const String databaseName = 'room_temperature';

  @override
  int get schemaVersion => 1;

  /// Appends one reading to the time series.
  ///
  /// [roomTemperatureSource] is the `name` of the domain enum value that
  /// produced [roomTemperatureC]; mapping it back to that enum is the
  /// caller's job.
  Future<void> insertReading({
    required double roomTemperatureC,
    required String roomTemperatureSource,
    required double outsideTemperatureC,
    required DateTime recordedAt,
  }) async {
    await into(readings).insert(
      ReadingsCompanion.insert(
        roomTemperatureC: roomTemperatureC,
        roomTemperatureSource: roomTemperatureSource,
        outsideTemperatureC: outsideTemperatureC,
        recordedAt: recordedAt,
      ),
    );
  }

  /// Watches the most recently recorded reading, emitting `null` while the
  /// time series is empty.
  Stream<ReadingRow?> watchLatestReading() {
    final query = select(readings)
      ..orderBy([(row) => OrderingTerm.desc(row.recordedAt)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  /// Folds one raw sample into the running sums for [day].
  ///
  /// [day] is normalized to midnight UTC, so any timestamp within a calendar
  /// day maps to that day's single row. Creates the row with a sample count
  /// of 1 when the day has no samples yet, and otherwise increments both
  /// sums and the count. The read and the write happen in one transaction so
  /// concurrent samples cannot lose an increment.
  Future<void> recordDailySample({
    required DateTime day,
    required double roomTemperatureC,
    required double outsideTemperatureC,
  }) {
    final normalizedDay = normalizeDay(day);

    return transaction(() async {
      final existing =
          await (select(dailyAverages)
                ..where((row) => row.day.equals(normalizedDay)))
              .getSingleOrNull();

      if (existing == null) {
        await into(dailyAverages).insert(
          DailyAveragesCompanion.insert(
            day: normalizedDay,
            sumRoomTempC: roomTemperatureC,
            sumOutsideTempC: outsideTemperatureC,
            sampleCount: 1,
          ),
        );
        return;
      }

      await (update(dailyAverages)
            ..where((row) => row.day.equals(normalizedDay)))
          .write(
            DailyAveragesCompanion(
              sumRoomTempC: Value(existing.sumRoomTempC + roomTemperatureC),
              sumOutsideTempC: Value(
                existing.sumOutsideTempC + outsideTemperatureC,
              ),
              sampleCount: Value(existing.sampleCount + 1),
            ),
          );
    });
  }

  /// Watches at most [limit] daily rows, most recent day first.
  Stream<List<DailyAverageRow>> watchRecentDailyAverages({int limit = 30}) {
    final query = select(dailyAverages)
      ..orderBy([(row) => OrderingTerm.desc(row.day)])
      ..limit(limit);
    return query.watch();
  }

  /// Reads the raw value stored under [key], or `null` when nothing has been
  /// written under it yet.
  Future<String?> readSetting(String key) async {
    final row = await (select(
      settingsRows,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Stores [value] under [key], replacing any previous value.
  Future<void> writeSetting(String key, String value) async {
    await into(settingsRows).insertOnConflictUpdate(
      SettingsRowsCompanion.insert(key: key, value: value),
    );
  }

  /// Watches the raw value stored under [key], emitting `null` while nothing
  /// has been written under it.
  Stream<String?> watchSetting(String key) {
    return (select(settingsRows)..where((row) => row.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  /// Reads every stored setting as a key/value map.
  Future<Map<String, String>> readSettings() async {
    final rows = await select(settingsRows).get();
    return {for (final row in rows) row.key: row.value};
  }

  /// Watches every stored setting as a key/value map, emitting on any
  /// change to any key.
  Stream<Map<String, String>> watchSettings() {
    return select(settingsRows).watch().map(
      (rows) => {for (final row in rows) row.key: row.value},
    );
  }

  /// Stores every entry of [values] in one transaction, replacing any
  /// previous value for those keys and leaving all other keys untouched.
  Future<void> writeSettings(Map<String, String> values) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(settingsRows, [
        for (final entry in values.entries)
          SettingsRowsCompanion.insert(key: entry.key, value: entry.value),
      ]);
    });
  }

  /// Normalizes [day] to midnight UTC, the form used as the
  /// [DailyAverages.day] primary key.
  static DateTime normalizeDay(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day);
}
