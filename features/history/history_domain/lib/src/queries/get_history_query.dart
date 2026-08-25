import 'package:history_domain/src/models/daily_average.dart';
import 'package:history_domain/src/repositories/i_history_repository.dart';

/// {@template get_history_query}
/// Watches a user's [DailyAverage] history via an [IHistoryRepository].
/// {@endtemplate}
class GetHistoryQuery {
  /// {@macro get_history_query}
  const GetHistoryQuery({required this._historyRepository});

  final IHistoryRepository _historyRepository;

  /// Watches the most recent [days] [DailyAverage]s for the user identified
  /// by [userId].
  Stream<List<DailyAverage>> watch({required String userId, int days = 30}) {
    return _historyRepository.watchHistory(userId: userId, days: days);
  }
}
