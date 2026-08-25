import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:test/test.dart';

void main() {
  group('FirestoreNotificationTokenRepository', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreNotificationTokenRepository repository;

    const userId = 'user-1';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = FirestoreNotificationTokenRepository(firestore: firestore);
    });

    test('saveToken merge-writes only the fcmToken field', () async {
      await repository.saveToken(userId: userId, token: 'token-abc');

      final snapshot = await firestore.collection('users').doc(userId).get();

      expect(snapshot.data(), {'fcmToken': 'token-abc'});
    });

    test('saveToken does not clobber fields owned by other features', () async {
      await firestore.collection('users').doc(userId).set({
        'units': 'metric',
        'thresholdMinC': 10,
      });

      await repository.saveToken(userId: userId, token: 'token-abc');

      final snapshot = await firestore.collection('users').doc(userId).get();

      expect(snapshot.data()!['units'], 'metric');
      expect(snapshot.data()!['thresholdMinC'], 10);
      expect(snapshot.data()!['fcmToken'], 'token-abc');
    });
  });
}
