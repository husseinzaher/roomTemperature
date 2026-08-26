import 'package:history_domain/history_domain.dart';
import 'package:local_database/local_database.dart';

/// {@template daily_average_converter}
/// Converts a Drift [DailyAverageRow] into the domain [DailyAverage] model.
///
/// The database stores running sums and a sample count rather than an
/// average, so the two averages are computed here on read. This is also the
/// boundary that keeps the generated Drift row types inside this package.
/// {@endtemplate}
class DailyAverageConverter {
  /// {@macro daily_average_converter}
  const DailyAverageConverter();

  /// Converts a stored [row] into a domain [DailyAverage], deriving both
  /// averages from the stored sums and sample count.
  ///
  /// A row with a [DailyAverageRow.sampleCount] of zero cannot exist — a row
  /// is only ever created by folding in its first sample — so no
  /// divide-by-zero guard is needed here.
  DailyAverage fromRow(DailyAverageRow row) {
    return DailyAverage(
      // Rows are keyed by midnight UTC; `toUtc()` undoes the local-time view
      // Drift hands back so the calendar day can never shift by a day.
      day: row.day.toUtc(),
      averageRoomTemperatureCelsius: row.sumRoomTempC / row.sampleCount,
      averageOutsideTemperatureCelsius: row.sumOutsideTempC / row.sampleCount,
      sampleCount: row.sampleCount,
    );
  }
}
