import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:test/test.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  group('FcmTokenListener', () {
    late FirebaseMessaging messaging;
    const listener = FcmTokenListener();

    setUp(() {
      messaging = MockFirebaseMessaging();
    });

    test('tokenRefreshes forwards onTokenRefresh', () {
      when(
        () => messaging.onTokenRefresh,
      ).thenAnswer((_) => Stream.value('new-token'));

      expect(listener.tokenRefreshes(messaging), emits('new-token'));
    });

    test('getCurrentToken forwards getToken', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => 'current-token');

      final token = await listener.getCurrentToken(messaging);

      expect(token, 'current-token');
    });

    test('getCurrentToken forwards a null token', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => null);

      final token = await listener.getCurrentToken(messaging);

      expect(token, isNull);
    });
  });
}
