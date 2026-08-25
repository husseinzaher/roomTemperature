import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignUpCommand extends Mock implements SignUpCommand {}

void main() {
  group('SignUpCubit', () {
    late SignUpCommand signUpCommand;

    setUp(() {
      signUpCommand = MockSignUpCommand();
    });

    test('initial state is SignUpState()', () {
      expect(SignUpCubit(signUpCommand).state, const SignUpState());
    });

    blocTest<SignUpCubit, SignUpState>(
      'emits [submitting, success] when sign-up succeeds and passwords match',
      setUp: () {
        when(
          () => signUpCommand.execute(
            email: 'a@b.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => const AuthUser(uid: 'uid'));
      },
      build: () => SignUpCubit(signUpCommand),
      act: (cubit) => cubit.submit(
        email: 'a@b.com',
        password: 'password',
        confirmPassword: 'password',
      ),
      expect: () => const [
        SignUpState(status: SignUpStatus.submitting),
        SignUpState(status: SignUpStatus.success),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      'emits [failure] with password-mismatch without calling the '
      'repository when passwords differ',
      build: () => SignUpCubit(signUpCommand),
      act: (cubit) => cubit.submit(
        email: 'a@b.com',
        password: 'password',
        confirmPassword: 'different',
      ),
      expect: () => const [
        SignUpState(
          status: SignUpStatus.failure,
          errorCode: 'password-mismatch',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => signUpCommand.execute(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    blocTest<SignUpCubit, SignUpState>(
      'emits [submitting, failure] with the AuthException code on failure',
      setUp: () {
        when(
          () => signUpCommand.execute(
            email: 'a@b.com',
            password: 'password',
          ),
        ).thenThrow(
          const AuthException(code: 'email-in-use', message: 'taken'),
        );
      },
      build: () => SignUpCubit(signUpCommand),
      act: (cubit) => cubit.submit(
        email: 'a@b.com',
        password: 'password',
        confirmPassword: 'password',
      ),
      expect: () => const [
        SignUpState(status: SignUpStatus.submitting),
        SignUpState(status: SignUpStatus.failure, errorCode: 'email-in-use'),
      ],
    );
  });
}
