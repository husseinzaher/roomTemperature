import 'package:auth_domain/auth_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('SendPasswordResetCommand', () {
    late IAuthRepository repository;
    late SendPasswordResetCommand command;

    setUp(() {
      repository = MockAuthRepository();
      command = SendPasswordResetCommand(repository);
    });

    test('delegates to repository.sendPasswordResetEmail', () async {
      when(
        () => repository.sendPasswordResetEmail(email: 'a@b.com'),
      ).thenAnswer((_) async {});

      await command.execute(email: 'a@b.com');

      verify(
        () => repository.sendPasswordResetEmail(email: 'a@b.com'),
      ).called(1);
    });

    test('propagates repository failures', () async {
      when(
        () => repository.sendPasswordResetEmail(email: 'a@b.com'),
      ).thenThrow(
        const AuthException(code: 'network-error', message: 'no network'),
      );

      expect(
        () => command.execute(email: 'a@b.com'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
