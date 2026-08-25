import 'package:auth_domain/auth_domain.dart';
import 'package:test/test.dart';

void main() {
  group('AuthException', () {
    test('exposes code and message', () {
      const exception = AuthException(
        code: 'invalid-credentials',
        message: 'The email or password is incorrect.',
      );

      expect(exception.code, 'invalid-credentials');
      expect(exception.message, 'The email or password is incorrect.');
    });

    test('toString includes code and message', () {
      const exception = AuthException(code: 'unknown', message: 'oops');

      expect(exception.toString(), contains('unknown'));
      expect(exception.toString(), contains('oops'));
    });

    test('is an Exception', () {
      expect(
        const AuthException(code: 'unknown', message: 'oops'),
        isA<Exception>(),
      );
    });
  });
}
