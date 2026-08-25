import 'package:settings_domain/src/models/user_settings.dart';
import 'package:settings_domain/src/repositories/i_settings_repository.dart';

/// {@template update_settings_command}
/// Persists a user's [UserSettings] via the injected [ISettingsRepository].
/// {@endtemplate}
class UpdateSettingsCommand {
  /// {@macro update_settings_command}
  const UpdateSettingsCommand(this._repository);

  final ISettingsRepository _repository;

  /// Persists [settings] for [userId].
  Future<void> execute({
    required String userId,
    required UserSettings settings,
  }) => _repository.updateSettings(userId: userId, settings: settings);
}
