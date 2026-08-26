import 'package:drift/drift.dart';

/// {@template daily_averages_table}
/// One row per calendar day holding the running sums and sample count that
/// the daily averages are derived from.
///
/// Averages are never stored: callers divide [DailyAverages.sumRoomTempC] and
/// [DailyAverages.sumOutsideTempC] by [DailyAverages.sampleCount] on read, so
/// folding in a new sample is a single increment that can never drift out of
/// sync with the stored average.
/// {@endtemplate}
@DataClassName('DailyAverageRow')
class DailyAverages extends Table {
  /// The calendar day this row covers, normalized to midnight UTC.
  DateTimeColumn get day => dateTime()();

  /// The sum of every room temperature sample recorded on [day], in Celsius.
  RealColumn get sumRoomTempC => real()();

  /// The sum of every outside temperature sample recorded on [day], in
  /// Celsius.
  RealColumn get sumOutsideTempC => real()();

  /// The number of samples folded into the sums on [day].
  IntColumn get sampleCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {day};
}
