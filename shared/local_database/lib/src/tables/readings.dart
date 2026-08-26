import 'package:drift/drift.dart';

/// {@template readings_table}
/// The time series of temperature readings recorded on this device.
///
/// Rows are append-only: every refresh inserts one row, and the newest row
/// (by [Readings.recordedAt]) is the current reading.
/// {@endtemplate}
@DataClassName('ReadingRow')
@TableIndex(name: 'readings_recorded_at', columns: {#recordedAt})
class Readings extends Table {
  /// The surrogate primary key of this reading.
  IntColumn get id => integer().autoIncrement()();

  /// The room temperature in Celsius.
  RealColumn get roomTemperatureC => real()();

  /// The name of the `RoomTemperatureSource` enum value that produced
  /// [roomTemperatureC].
  TextColumn get roomTemperatureSource => text()();

  /// The outside temperature in Celsius at the time of this reading.
  RealColumn get outsideTemperatureC => real()();

  /// When this reading was taken.
  DateTimeColumn get recordedAt => dateTime()();
}
