import 'package:app_localization/app_localization.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSignUpCommand extends Mock implements SignUpCommand {}

void main() {
  group('SignUpPage', () {
    late SignUpCommand signUpCommand;

    setUp(() {
      signUpCommand = MockSignUpCommand();
    });

    Widget buildSubject() {
      return MultiProvider(
        providers: [
          Provider<SignUpCommand>.value(value: signUpCommand),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignUpPage(onNavigateToLogin: () {}),
        ),
      );
    }

    testWidgets(
      'renders email, password, confirm-password fields and a '
      'sign-up button',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.byType(TextFormField), findsNWidgets(3));
        expect(find.text('Sign Up'), findsOneWidget);
        expect(find.text('Log In'), findsOneWidget);
      },
    );

    testWidgets(
      'shows a mismatch error and does not call the command when '
      'passwords differ',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password');
        await tester.enterText(find.byType(TextFormField).at(2), 'different');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match.'), findsOneWidget);
        verifyNever(
          () => signUpCommand.execute(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    testWidgets(
      'submitting with matching passwords calls SignUpCommand.execute',
      (tester) async {
        when(
          () => signUpCommand.execute(
            email: 'a@b.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => const AuthUser(uid: 'uid'));

        await tester.pumpWidget(buildSubject());

        await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password');
        await tester.enterText(find.byType(TextFormField).at(2), 'password');
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        verify(
          () => signUpCommand.execute(
            email: 'a@b.com',
            password: 'password',
          ),
        ).called(1);
      },
    );
  });
}
