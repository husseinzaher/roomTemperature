import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';

/// {@template fcm_token_sync}
/// Keeps the signed-in user's FCM token in sync with Firestore: saves the
/// current token (and every refreshed token) via
/// [FirestoreNotificationTokenRepository.saveToken].
/// {@endtemplate}
class FcmTokenSync {
  /// {@macro fcm_token_sync}
  FcmTokenSync({
    required this.tokenRepository,
    FirebaseMessaging? messaging,
    FcmTokenListener? listener,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _listener = listener ?? const FcmTokenListener();

  /// Where refreshed tokens are persisted.
  final INotificationTokenRepository tokenRepository;

  final FirebaseMessaging _messaging;
  final FcmTokenListener _listener;

  StreamSubscription<String>? _subscription;

  /// Starts syncing [userId]'s FCM token: saves the current token
  /// immediately, then keeps saving it whenever it's refreshed.
  Future<void> start(String userId) async {
    final currentToken = await _listener.getCurrentToken(_messaging);
    if (currentToken != null) {
      await tokenRepository.saveToken(userId: userId, token: currentToken);
    }

    await _subscription?.cancel();
    _subscription = _listener.tokenRefreshes(_messaging).listen((token) {
      unawaited(tokenRepository.saveToken(userId: userId, token: token));
    });
  }

  /// Stops syncing tokens, e.g. on sign-out.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
