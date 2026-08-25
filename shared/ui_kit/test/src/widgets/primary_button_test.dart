import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('shows the label and calls onPressed when tapped', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Save',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(pressed, isTrue);
    });

    testWidgets('shows a spinner and disables tap when isLoading', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Save',
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Save'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(pressed, isFalse);
    });
  });
}
