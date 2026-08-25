import 'package:auth_data/auth_data.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFirebaseAuthException extends Mock
    implements firebase_auth.FirebaseAuthException {}

void main() {
  group('FirebaseAuthExceptionConverter', () {
    const converter = FirebaseAuthExceptionConverter();

    MockFirebaseAuthException exceptionWith(String code) {
      final exception = MockFirebaseAuthException();
      when(() => exception.code).thenReturn(code);
      when(() => exception.message).thenReturn('message for $code');
      return exception;
    }

    test('maps user-not-found to invalid-credentials', () {
      final result = converter.convert(exceptionWith('user-not-found'));
      expect(result.code, 'invalid-credentials');
    });

    test('maps wrong-password to invalid-credentials', () {
      final result = converter.convert(exceptionWith('wrong-password'));
      expect(result.code, 'invalid-credentials');
    });

    test('maps invalid-credential to invalid-credentials', () {
      final result = converter.convert(exceptionWith('invalid-credential'));
      expect(result.code, 'invalid-credentials');
    });

    test('maps invalid-email to invalid-credentials', () {
      final result = converter.convert(exceptionWith('invalid-email'));
      expect(result.code, 'invalid-credentials');
    });

    test('maps email-already-in-use to email-in-use', () {
      final result = converter.convert(exceptionWith('email-already-in-use'));
      expect(result.code, 'email-in-use');
    });

    test('maps weak-password to weak-password', () {
      final result = converter.convert(exceptionWith('weak-password'));
      expect(result.code, 'weak-password');
    });

    test('maps network-request-failed to network-error', () {
      final result = converter.convert(exceptionWith('network-request-failed'));
      expect(result.code, 'network-error');
    });

    test('maps unrecognized codes to unknown', () {
      final result = converter.convert(exceptionWith('some-other-code'));
      expect(result.code, 'unknown');
    });

    test('preserves the original message', () {
      final result = converter.convert(exceptionWith('weak-password'));
      expect(result.message, 'message for weak-password');
    });
  });
}
