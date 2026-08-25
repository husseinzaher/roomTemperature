import 'package:firebase_messaging/firebase_messaging.dart';

/// {@template fcm_token_listener}
/// Thin wrapper around [FirebaseMessaging] token APIs.
///
/// Kept intentionally minimal — wiring "on new token, persist it" is an
/// app-layer concern (e.g. via an
/// `INotificationTokenRepository.saveToken` call).
/// {@endtemplate}
class FcmTokenListener {
  /// {@macro fcm_token_listener}
  const FcmTokenListener();

  /// Streams a new token string whenever [messaging] refreshes it.
  Stream<String> tokenRefreshes(FirebaseMessaging messaging) {
    return messaging.onTokenRefresh;
  }

  /// Fetches the current FCM token for [messaging], if any.
  Future<String?> getCurrentToken(FirebaseMessaging messaging) {
    return messaging.getToken();
  }
}
