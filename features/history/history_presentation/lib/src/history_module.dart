import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/src/cubit/history_cubit.dart';

/// {@template history_module}
/// Wires up a [HistoryCubit] and provides it to [child] via [BlocProvider].
///
/// This is the single entry point app-assembly code should use to mount the
/// history feature.
/// {@endtemplate}
class HistoryModule extends StatelessWidget {
  /// {@macro history_module}
  const HistoryModule({
    required this.userId,
    required this.historyRepository,
    required this.child,
    super.key,
  });

  /// The id of the user this module tracks history for.
  final String userId;

  /// Persists and streams the user's daily average history.
  final IHistoryRepository historyRepository;

  /// The subtree that can access the provided [HistoryCubit].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(
        userId: userId,
        historyRepository: historyRepository,
      ),
      child: child,
    );
  }
}
