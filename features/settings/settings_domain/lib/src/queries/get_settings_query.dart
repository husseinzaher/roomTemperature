import 'package:settings_domain/src/models/user_settings.dart';
import 'package:settings_domain/src/repositories/i_settings_repository.dart';

/// {@template get_settings_query}
/// Watches the stored [UserSettings] via the injected [ISettingsRepository].
/// {@endtemplate}
class GetSettingsQuery {
  /// {@macro get_settings_query}
  const GetSettingsQuery(this._repository);

  final ISettingsRepository _repository;

  /// Emits the stored [UserSettings] every time they change.
  Stream<UserSettings> watch() => _repository.watchSettings();
}
