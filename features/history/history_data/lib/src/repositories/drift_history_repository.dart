import 'package:history_data/src/converters/daily_average_converter.dart';
import 'package:history_domain/history_domain.dart';
import 'package:local_database/local_database.dart';

/// {@template drift_history_repository}
/// An [IHistoryRepository] backed by the on-device Drift database.
///
/// Each day is one row of running sums plus a sample count, so folding in a
/// new sample is a single transactional increment and the averages are
/// derived on read.
/// {@endtemplate}
class DriftHistoryRepository implements IHistoryRepository {
  /// {@macro drift_history_repository}
  const DriftHistoryRepository({
    required AppDatabase database,
    DailyAverageConverter converter = const DailyAverageConverter(),
  }) : _database = database,
       _converter = converter;

  final AppDatabase _database;
  final DailyAverageConverter _converter;

  @override
  Stream<List<DailyAverage>> watchHistory({int days = 30}) {
    return _database
        .watchRecentDailyAverages(limit: days)
        .map((rows) => rows.map(_converter.fromRow).toList());
  }

  @override
  Future<void> recordSample({
    required DateTime day,
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
  }) {
    return _database.recordDailySample(
      day: day,
      roomTemperatureC: roomTemperatureCelsius,
      outsideTemperatureC: outsideTemperatureCelsius,
    );
  }
}
