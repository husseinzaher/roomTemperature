import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('AuthModule', () {
    late IAuthRepository authRepository;

    setUp(() {
      authRepository = MockAuthRepository();
      when(
        () => authRepository.watchAuthState(),
      ).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('exposes commands and queries built from the repository', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        AuthModule(
          authRepository: authRepository,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(capturedContext.read<IAuthRepository>(), authRepository);
      expect(capturedContext.read<SignInCommand>(), isA<SignInCommand>());
      expect(capturedContext.read<SignUpCommand>(), isA<SignUpCommand>());
      expect(capturedContext.read<SignOutCommand>(), isA<SignOutCommand>());
      expect(
        capturedContext.read<SendPasswordResetCommand>(),
        isA<SendPasswordResetCommand>(),
      );
      expect(
        capturedContext.read<WatchAuthStateQuery>(),
        isA<WatchAuthStateQuery>(),
      );
      expect(
        capturedContext.read<AuthStatusCubit>(),
        isA<AuthStatusCubit>(),
      );
    });
  });
}
