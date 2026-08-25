import 'package:app_localization/app_localization.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSendPasswordResetCommand extends Mock
    implements SendPasswordResetCommand {}

void main() {
  group('ForgotPasswordPage', () {
    late SendPasswordResetCommand command;

    setUp(() {
      command = MockSendPasswordResetCommand();
    });

    Widget buildSubject() {
      return MultiProvider(
        providers: [
          Provider<SendPasswordResetCommand>.value(value: command),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ForgotPasswordPage(onNavigateToLogin: () {}),
        ),
      );
    }

    testWidgets('renders an email field and a send-reset-link button', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Send reset link'), findsOneWidget);
    });

    testWidgets(
      'submitting calls SendPasswordResetCommand.execute and shows the '
      'check-your-email view on success',
      (tester) async {
        when(() => command.execute(email: 'a@b.com')).thenAnswer(
          (_) async {},
        );

        await tester.pumpWidget(buildSubject());

        await tester.enterText(find.byType(TextFormField), 'a@b.com');
        await tester.tap(find.text('Send reset link'));
        await tester.pumpAndSettle();

        verify(() => command.execute(email: 'a@b.com')).called(1);
        expect(find.text('Check your email'), findsOneWidget);
      },
    );

    testWidgets('shows an error banner on failure', (tester) async {
      when(() => command.execute(email: 'a@b.com')).thenThrow(
        const AuthException(code: 'network-error', message: 'no network'),
      );

      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextFormField), 'a@b.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't connect to the network. Check your connection."),
        findsOneWidget,
      );
    });
  });
}
