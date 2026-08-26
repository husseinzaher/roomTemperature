import 'package:settings_domain/src/models/user_settings.dart';

/// {@template i_settings_repository}
/// Contract for reading and writing this device's [UserSettings],
/// implemented by the data layer (e.g. a Drift-backed repository) and
/// consumed by the domain's commands and queries.
/// {@endtemplate}
abstract interface class ISettingsRepository {
  /// Emits the stored [UserSettings] every time they change.
  Stream<UserSettings> watchSettings();

  /// Persists [settings].
  ///
  /// Implementations must only write the fields owned by this feature and
  /// must not clobber values owned by other features in the same store.
  Future<void> updateSettings({required UserSettings settings});
}
