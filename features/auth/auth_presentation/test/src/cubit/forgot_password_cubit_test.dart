import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSendPasswordResetCommand extends Mock
    implements SendPasswordResetCommand {}

void main() {
  group('ForgotPasswordCubit', () {
    late SendPasswordResetCommand command;

    setUp(() {
      command = MockSendPasswordResetCommand();
    });

    test('initial state is ForgotPasswordState()', () {
      expect(
        ForgotPasswordCubit(command).state,
        const ForgotPasswordState(),
      );
    });

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'emits [submitting, sent] when the request succeeds',
      setUp: () {
        when(() => command.execute(email: 'a@b.com')).thenAnswer((_) async {});
      },
      build: () => ForgotPasswordCubit(command),
      act: (cubit) => cubit.submit(email: 'a@b.com'),
      expect: () => const [
        ForgotPasswordState(status: ForgotPasswordStatus.submitting),
        ForgotPasswordState(status: ForgotPasswordStatus.sent),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'emits [submitting, failure] with the AuthException code on failure',
      setUp: () {
        when(() => command.execute(email: 'a@b.com')).thenThrow(
          const AuthException(code: 'network-error', message: 'no network'),
        );
      },
      build: () => ForgotPasswordCubit(command),
      act: (cubit) => cubit.submit(email: 'a@b.com'),
      expect: () => const [
        ForgotPasswordState(status: ForgotPasswordStatus.submitting),
        ForgotPasswordState(
          status: ForgotPasswordStatus.failure,
          errorCode: 'network-error',
        ),
      ],
    );
  });
}
