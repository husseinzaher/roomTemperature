import 'package:settings_domain/src/models/user_settings.dart';

/// {@template i_settings_repository}
/// Contract for reading and writing a user's [UserSettings], implemented by
/// the data layer (e.g. a Firestore-backed repository) and consumed by the
/// domain's commands and queries.
/// {@endtemplate}
abstract interface class ISettingsRepository {
  /// Emits the [UserSettings] for [userId] every time they change.
  Stream<UserSettings> watchSettings({required String userId});

  /// Persists [settings] for [userId].
  ///
  /// Implementations must only write the fields owned by this feature and
  /// must not clobber fields owned by other features on the same user
  /// profile document.
  Future<void> updateSettings({
    required String userId,
    required UserSettings settings,
  });
}
