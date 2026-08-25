import 'package:equatable/equatable.dart';
import 'package:history_domain/history_domain.dart';

/// The lifecycle status of a [HistoryState].
enum HistoryStatus {
  /// History is being fetched for the first time.
  loading,

  /// History is available.
  loaded,

  /// The history stream emitted an error.
  error,
}

/// {@template history_state}
/// State for `HistoryCubit`.
///
/// [items] may be non-empty even while [status] is [HistoryStatus.error] —
/// the most recently known history is preserved when the stream errors, so
/// the UI can keep showing stale data alongside the error.
/// {@endtemplate}
class HistoryState extends Equatable {
  /// {@macro history_state}
  const HistoryState({
    this.status = HistoryStatus.loading,
    this.items = const [],
    this.errorMessage,
  });

  /// The initial state: loading, with no history yet.
  const HistoryState.loading({this.items = const []})
    : status = HistoryStatus.loading,
      errorMessage = null;

  /// A state with successfully loaded [items].
  const HistoryState.loaded({required this.items})
    : status = HistoryStatus.loaded,
      errorMessage = null;

  /// A state where the history stream emitted [errorMessage], optionally
  /// preserving previously loaded [items].
  const HistoryState.error({
    required String this.errorMessage,
    this.items = const [],
  }) : status = HistoryStatus.error;

  /// The current lifecycle status.
  final HistoryStatus status;

  /// The most recently known daily averages, ordered most recent first.
  final List<DailyAverage> items;

  /// A human-readable error message, set only when [status] is
  /// [HistoryStatus.error].
  final String? errorMessage;

  @override
  List<Object?> get props => [status, items, errorMessage];
}
