import 'package:auth_domain/auth_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('SignOutCommand', () {
    late IAuthRepository repository;
    late SignOutCommand command;

    setUp(() {
      repository = MockAuthRepository();
      command = SignOutCommand(repository);
    });

    test('delegates to repository.signOut', () async {
      when(() => repository.signOut()).thenAnswer((_) async {});

      await command.execute();

      verify(() => repository.signOut()).called(1);
    });

    test('propagates repository failures', () async {
      when(() => repository.signOut()).thenThrow(
        const AuthException(code: 'unknown', message: 'oops'),
      );

      expect(command.execute, throwsA(isA<AuthException>()));
    });
  });
}
