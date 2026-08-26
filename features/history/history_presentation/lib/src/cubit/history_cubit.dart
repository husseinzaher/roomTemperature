import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/src/cubit/history_state.dart';

/// {@template history_cubit}
/// Subscribes to the stored [DailyAverage] history and streams
/// loaded/error states as it changes.
/// {@endtemplate}
class HistoryCubit extends Cubit<HistoryState> {
  /// {@macro history_cubit}
  HistoryCubit({
    required IHistoryRepository historyRepository,
    int days = 30,
  }) : super(const HistoryState.loading()) {
    _subscription = historyRepository
        .watchHistory(days: days)
        .listen(_onHistoryReceived, onError: _onWatchError);
  }

  StreamSubscription<List<DailyAverage>>? _subscription;

  void _onHistoryReceived(List<DailyAverage> items) {
    emit(HistoryState.loaded(items: items));
  }

  void _onWatchError(Object error) {
    emit(
      HistoryState.error(errorMessage: error.toString(), items: state.items),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
