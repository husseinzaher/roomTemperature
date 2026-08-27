import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/src/cubit/settings_cubit.dart';

/// {@template settings_module}
/// Wires up a [SettingsCubit] and provides it to [child] via
/// [BlocProvider].
///
/// This is the single entry point app-assembly code should use to mount the
/// settings feature: it takes a concrete [settingsRepository] and builds
/// the cubit from it.
/// {@endtemplate}
class SettingsModule extends StatelessWidget {
  /// {@macro settings_module}
  const SettingsModule({
    required this.settingsRepository,
    required this.child,
    super.key,
  });

  /// Reads and persists this device's settings.
  final ISettingsRepository settingsRepository;

  /// The subtree that can access the provided [SettingsCubit].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(settingsRepository: settingsRepository),
      child: child,
    );
  }
}
