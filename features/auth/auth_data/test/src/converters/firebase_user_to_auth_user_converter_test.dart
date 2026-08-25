import 'package:auth_data/auth_data.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockUser extends Mock implements firebase_auth.User {}

void main() {
  group('FirebaseUserToAuthUserConverter', () {
    const converter = FirebaseUserToAuthUserConverter();

    test('maps uid, email, displayName', () {
      final user = MockUser();
      when(() => user.uid).thenReturn('uid');
      when(() => user.email).thenReturn('a@b.com');
      when(() => user.displayName).thenReturn('A');

      final result = converter.convert(user);

      expect(result.uid, 'uid');
      expect(result.email, 'a@b.com');
      expect(result.displayName, 'A');
    });

    test('maps null email and displayName', () {
      final user = MockUser();
      when(() => user.uid).thenReturn('uid');
      when(() => user.email).thenReturn(null);
      when(() => user.displayName).thenReturn(null);

      final result = converter.convert(user);

      expect(result.email, isNull);
      expect(result.displayName, isNull);
    });
  });
}
