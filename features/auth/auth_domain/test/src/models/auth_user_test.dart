import 'package:auth_domain/auth_domain.dart';
import 'package:test/test.dart';

void main() {
  group('AuthUser', () {
    test('supports value equality', () {
      expect(
        const AuthUser(uid: 'uid', email: 'a@b.com', displayName: 'A'),
        equals(const AuthUser(uid: 'uid', email: 'a@b.com', displayName: 'A')),
      );
    });

    test('props include uid, email, displayName', () {
      const user = AuthUser(uid: 'uid', email: 'a@b.com', displayName: 'A');
      expect(user.props, ['uid', 'a@b.com', 'A']);
    });

    test('differs when uid differs', () {
      expect(
        const AuthUser(uid: 'uid-1'),
        isNot(equals(const AuthUser(uid: 'uid-2'))),
      );
    });

    test('email and displayName are nullable', () {
      const user = AuthUser(uid: 'uid');
      expect(user.email, isNull);
      expect(user.displayName, isNull);
    });
  });
}
