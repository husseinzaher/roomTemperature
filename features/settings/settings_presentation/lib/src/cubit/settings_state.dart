import 'package:equatable/equatable.dart';
import 'package:settings_domain/settings_domain.dart';

/// The lifecycle status of a [SettingsState].
enum SettingsStatus {
  /// Settings are being loaded for the first time.
  loading,

  /// Settings are available.
  loaded,

  /// A save is in flight. [SettingsState.settings] already reflects the
  /// optimistically-applied update.
  saving,

  /// The most recent load or save failed.
  error,
}

/// {@template settings_state}
/// State for SettingsCubit.
/// {@endtemplate}
class SettingsState extends Equatable {
  /// {@macro settings_state}
  const SettingsState({
    this.status = SettingsStatus.loading,
    this.settings,
    this.errorMessage,
  });

  /// The initial state: loading, with no settings yet.
  const SettingsState.loading({this.settings})
    : status = SettingsStatus.loading,
      errorMessage = null;

  /// A state with successfully loaded or saved [settings].
  const SettingsState.loaded({required UserSettings this.settings})
    : status = SettingsStatus.loaded,
      errorMessage = null;

  /// A state where [settings] is being saved, optimistically reflecting the
  /// update that is in flight.
  const SettingsState.saving({required UserSettings this.settings})
    : status = SettingsStatus.saving,
      errorMessage = null;

  /// A state where the most recent load or save failed with
  /// [errorMessage], optionally preserving a previously known [settings].
  const SettingsState.error({required String this.errorMessage, this.settings})
    : status = SettingsStatus.error;

  /// The current lifecycle status.
  final SettingsStatus status;

  /// The most recently known settings, if any.
  final UserSettings? settings;

  /// A human-readable error message, set only when [status] is
  /// [SettingsStatus.error].
  final String? errorMessage;

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
