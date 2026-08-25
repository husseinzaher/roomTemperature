import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    testWidgets('resolves the English app title', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Text(context.l10n.appTitle);
            },
          ),
        ),
      );

      expect(find.text('Room Temperature'), findsOneWidget);
      expect(capturedContext.l10n.login, 'Log In');
    });

    testWidgets('resolves the Arabic app title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Text(context.l10n.appTitle),
          ),
        ),
      );

      expect(find.text('درجة حرارة الغرفة'), findsOneWidget);
    });

    testWidgets('formats the threshold exceeded body placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) =>
                Text(context.l10n.thresholdExceededBody(27.5)),
          ),
        ),
      );

      expect(find.textContaining('27.5'), findsOneWidget);
    });
  });
}
