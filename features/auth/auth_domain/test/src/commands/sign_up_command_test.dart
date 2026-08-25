import 'package:auth_domain/auth_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('SignUpCommand', () {
    late IAuthRepository repository;
    late SignUpCommand command;

    setUp(() {
      repository = MockAuthRepository();
      command = SignUpCommand(repository);
    });

    test('delegates to repository.signUp', () async {
      const user = AuthUser(uid: 'uid');
      when(
        () => repository.signUp(
          email: 'a@b.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => user);

      final result = await command.execute(
        email: 'a@b.com',
        password: 'password',
      );

      expect(result, user);
      verify(
        () => repository.signUp(email: 'a@b.com', password: 'password'),
      ).called(1);
    });

    test('propagates repository failures', () async {
      when(
        () => repository.signUp(
          email: 'a@b.com',
          password: 'weak',
        ),
      ).thenThrow(
        const AuthException(code: 'weak-password', message: 'too weak'),
      );

      expect(
        () => command.execute(email: 'a@b.com', password: 'weak'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
