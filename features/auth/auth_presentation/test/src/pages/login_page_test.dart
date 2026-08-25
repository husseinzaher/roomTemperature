import 'package:app_localization/app_localization.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSignInCommand extends Mock implements SignInCommand {}

void main() {
  group('LoginPage', () {
    late SignInCommand signInCommand;

    setUp(() {
      signInCommand = MockSignInCommand();
    });

    Widget buildSubject() {
      return MultiProvider(
        providers: [
          Provider<SignInCommand>.value(value: signInCommand),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(
            onNavigateToSignUp: () {},
            onNavigateToForgotPassword: () {},
          ),
        ),
      );
    }

    testWidgets('renders email, password fields and a login button', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('submitting calls SignInCommand.execute with entered '
        'credentials', (tester) async {
      when(
        () => signInCommand.execute(
          email: 'a@b.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => const AuthUser(uid: 'uid'));

      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.enterText(find.byType(TextFormField).last, 'password');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      verify(
        () => signInCommand.execute(email: 'a@b.com', password: 'password'),
      ).called(1);
    });

    testWidgets('shows an error banner on failure', (tester) async {
      when(
        () => signInCommand.execute(
          email: 'a@b.com',
          password: 'wrong',
        ),
      ).thenThrow(
        const AuthException(code: 'invalid-credentials', message: 'nope'),
      );

      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrong');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });
  });
}
