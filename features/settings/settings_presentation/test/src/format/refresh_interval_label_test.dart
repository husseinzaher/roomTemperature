import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_presentation/settings_presentation.dart';

void main() {
  testWidgets('labels 1 minute through 24 hours', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      refreshIntervalLabel(const Duration(minutes: 1), l10n),
      '1 minute',
    );
    expect(
      refreshIntervalLabel(const Duration(minutes: 5), l10n),
      '5 minutes',
    );
    expect(
      refreshIntervalLabel(const Duration(minutes: 15), l10n),
      '15 minutes',
    );
    expect(
      refreshIntervalLabel(const Duration(hours: 1), l10n),
      '1 hour',
    );
    expect(
      refreshIntervalLabel(const Duration(hours: 24), l10n),
      '24 hours',
    );
  });
}
