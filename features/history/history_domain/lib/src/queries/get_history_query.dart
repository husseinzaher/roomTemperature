import 'package:history_domain/src/models/daily_average.dart';
import 'package:history_domain/src/repositories/i_history_repository.dart';

/// {@template get_history_query}
/// Watches the [DailyAverage] history via an [IHistoryRepository].
/// {@endtemplate}
class GetHistoryQuery {
  /// {@macro get_history_query}
  const GetHistoryQuery({required this._historyRepository});

  final IHistoryRepository _historyRepository;

  /// Watches the most recent [days] [DailyAverage]s.
  Stream<List<DailyAverage>> watch({int days = 30}) {
    return _historyRepository.watchHistory(days: days);
  }
}
