import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('ThresholdStatusBadge', () {
    testWidgets('renders "Normal" for normal status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThresholdStatusBadge(status: ThresholdStatus.normal),
          ),
        ),
      );

      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('renders "Above threshold" for above status', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThresholdStatusBadge(status: ThresholdStatus.above),
          ),
        ),
      );

      expect(find.text('Above threshold'), findsOneWidget);
    });

    testWidgets('renders "Below threshold" for below status', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThresholdStatusBadge(status: ThresholdStatus.below),
          ),
        ),
      );

      expect(find.text('Below threshold'), findsOneWidget);
    });
  });
}
