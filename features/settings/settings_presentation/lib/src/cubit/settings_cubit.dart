import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/src/cubit/settings_state.dart';

/// {@template settings_cubit}
/// Loads, streams, and saves the stored [UserSettings].
///
/// Subscribes to [ISettingsRepository.watchSettings] as soon as it is
/// constructed. [save] applies the update optimistically (emitting a
/// [SettingsStatus.saving] state with the new settings immediately) and then
/// relies on that same live stream to confirm the write once it round-trips
/// through storage, falling back to an error state if the write itself
/// throws.
/// {@endtemplate}
class SettingsCubit extends Cubit<SettingsState> {
  /// {@macro settings_cubit}
  SettingsCubit({required ISettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(const SettingsState.loading()) {
    _subscription = settingsRepository.watchSettings().listen(
      _onSettingsReceived,
      onError: _onWatchError,
    );
  }

  final ISettingsRepository _settingsRepository;

  StreamSubscription<UserSettings>? _subscription;

  void _onSettingsReceived(UserSettings settings) {
    emit(SettingsState.loaded(settings: settings));
  }

  void _onWatchError(Object error) {
    emit(
      SettingsState.error(
        errorMessage: error.toString(),
        settings: state.settings,
      ),
    );
  }

  /// Optimistically applies [updated], persists it via the injected
  /// repository, and relies on the live [ISettingsRepository.watchSettings]
  /// stream to confirm the write once it round-trips through storage.
  ///
  /// Falls back to a [SettingsStatus.error] state, preserving [updated], if
  /// the write itself throws.
  Future<void> save(UserSettings updated) async {
    emit(SettingsState.saving(settings: updated));
    try {
      await _settingsRepository.updateSettings(settings: updated);
    } on Exception catch (error) {
      emit(
        SettingsState.error(errorMessage: error.toString(), settings: updated),
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
