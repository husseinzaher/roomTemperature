import 'package:settings_domain/src/models/user_settings.dart';
import 'package:settings_domain/src/repositories/i_settings_repository.dart';

/// {@template update_settings_command}
/// Persists [UserSettings] via the injected [ISettingsRepository].
/// {@endtemplate}
class UpdateSettingsCommand {
  /// {@macro update_settings_command}
  const UpdateSettingsCommand(this._repository);

  final ISettingsRepository _repository;

  /// Persists [settings].
  Future<void> execute({required UserSettings settings}) =>
      _repository.updateSettings(settings: settings);
}
