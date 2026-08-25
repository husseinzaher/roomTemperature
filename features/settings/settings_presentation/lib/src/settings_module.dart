import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/src/cubit/settings_cubit.dart';

/// {@template settings_module}
/// Wires up a [SettingsCubit] and provides it to [child] via
/// [BlocProvider].
///
/// This is the single entry point app-assembly code should use to mount the
/// settings feature: it takes a concrete [settingsRepository] and the
/// [userId] to track, and builds the cubit from them.
/// {@endtemplate}
class SettingsModule extends StatelessWidget {
  /// {@macro settings_module}
  const SettingsModule({
    required this.userId,
    required this.settingsRepository,
    required this.child,
    super.key,
  });

  /// The id of the user this module tracks settings for.
  final String userId;

  /// Reads and persists the user's settings.
  final ISettingsRepository settingsRepository;

  /// The subtree that can access the provided [SettingsCubit].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        userId: userId,
        settingsRepository: settingsRepository,
      ),
      child: child,
    );
  }
}
