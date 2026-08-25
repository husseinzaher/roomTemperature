import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('AppTheme', () {
    test('light() builds a valid Material 3 ThemeData', () {
      final theme = AppTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('dark() builds a valid Material 3 ThemeData', () {
      final theme = AppTheme.dark();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('light theme can be used to pump a widget tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: Text('hello')),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('dark theme can be used to pump a widget tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: Text('hello')),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
    });
  });
}
