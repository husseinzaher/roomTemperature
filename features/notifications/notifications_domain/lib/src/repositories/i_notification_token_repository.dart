/// {@template i_notification_token_repository}
/// Persists a push-notification delivery token for a user.
/// {@endtemplate}
// ignore: one_member_abstracts
abstract interface class INotificationTokenRepository {
  /// Saves [token] as the push-notification delivery token for the user
  /// identified by [userId].
  Future<void> saveToken({required String userId, required String token});
}
