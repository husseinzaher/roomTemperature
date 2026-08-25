import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInCommand extends Mock implements SignInCommand {}

void main() {
  group('LoginCubit', () {
    late SignInCommand signInCommand;

    setUp(() {
      signInCommand = MockSignInCommand();
    });

    test('initial state is LoginState()', () {
      expect(LoginCubit(signInCommand).state, const LoginState());
    });

    blocTest<LoginCubit, LoginState>(
      'emits [submitting, success] when sign-in succeeds',
      setUp: () {
        when(
          () => signInCommand.execute(
            email: 'a@b.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => const AuthUser(uid: 'uid'));
      },
      build: () => LoginCubit(signInCommand),
      act: (cubit) => cubit.submit(email: 'a@b.com', password: 'password'),
      expect: () => const [
        LoginState(status: LoginStatus.submitting),
        LoginState(status: LoginStatus.success),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [submitting, failure] with the AuthException code on failure',
      setUp: () {
        when(
          () => signInCommand.execute(
            email: 'a@b.com',
            password: 'wrong',
          ),
        ).thenThrow(
          const AuthException(code: 'invalid-credentials', message: 'nope'),
        );
      },
      build: () => LoginCubit(signInCommand),
      act: (cubit) => cubit.submit(email: 'a@b.com', password: 'wrong'),
      expect: () => const [
        LoginState(status: LoginStatus.submitting),
        LoginState(
          status: LoginStatus.failure,
          errorCode: 'invalid-credentials',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits failure with unknown code on unexpected error',
      setUp: () {
        when(
          () => signInCommand.execute(
            email: 'a@b.com',
            password: 'wrong',
          ),
        ).thenThrow(Exception('boom'));
      },
      build: () => LoginCubit(signInCommand),
      act: (cubit) => cubit.submit(email: 'a@b.com', password: 'wrong'),
      expect: () => const [
        LoginState(status: LoginStatus.submitting),
        LoginState(status: LoginStatus.failure, errorCode: 'unknown'),
      ],
    );
  });
}
