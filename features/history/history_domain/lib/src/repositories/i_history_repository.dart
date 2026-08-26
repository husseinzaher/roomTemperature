import 'package:history_domain/src/models/daily_average.dart';

/// {@template i_history_repository}
/// Persists and streams this device's [DailyAverage] history.
/// {@endtemplate}
abstract interface class IHistoryRepository {
  /// Watches the most recent [days] [DailyAverage]s, ordered most recent
  /// first.
  Stream<List<DailyAverage>> watchHistory({int days = 30});

  /// Incorporates one new raw sample into the running average for [day].
  ///
  /// Implementations decide how the running average is updated — e.g. via a
  /// transaction that reads the existing count/sum for [day] and writes back
  /// the incremented values.
  Future<void> recordSample({
    required DateTime day,
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
  });
}
