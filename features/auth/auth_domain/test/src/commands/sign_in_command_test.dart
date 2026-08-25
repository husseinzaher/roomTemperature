import 'package:auth_domain/auth_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('SignInCommand', () {
    late IAuthRepository repository;
    late SignInCommand command;

    setUp(() {
      repository = MockAuthRepository();
      command = SignInCommand(repository);
    });

    test('delegates to repository.signIn', () async {
      const user = AuthUser(uid: 'uid');
      when(
        () => repository.signIn(
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
        () => repository.signIn(email: 'a@b.com', password: 'password'),
      ).called(1);
    });

    test('propagates repository failures', () async {
      when(
        () => repository.signIn(
          email: 'a@b.com',
          password: 'wrong',
        ),
      ).thenThrow(
        const AuthException(code: 'invalid-credentials', message: 'nope'),
      );

      expect(
        () => command.execute(email: 'a@b.com', password: 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
