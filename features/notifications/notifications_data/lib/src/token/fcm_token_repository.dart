import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifications_domain/notifications_domain.dart';

/// {@template firestore_notification_token_repository}
/// An [INotificationTokenRepository] that merge-writes the FCM token onto
/// the user's `users/{userId}` document.
///
/// This document is shared with other features (e.g. settings, which
/// merge-writes fields such as `units` and `thresholdMinC`), so this
/// repository only ever merge-writes the single `fcmToken` field — it must
/// never overwrite the whole document.
/// {@endtemplate}
class FirestoreNotificationTokenRepository
    implements INotificationTokenRepository {
  /// {@macro firestore_notification_token_repository}
  FirestoreNotificationTokenRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> saveToken({required String userId, required String token}) {
    return _firestore.collection('users').doc(userId).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }
}
