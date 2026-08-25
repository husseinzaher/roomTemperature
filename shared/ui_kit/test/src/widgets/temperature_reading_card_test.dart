import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('TemperatureReadingCard', () {
    testWidgets('shows label, value and the Sensor chip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TemperatureReadingCard(
              label: 'Room',
              temperatureCelsius: 21.4,
              icon: Icons.home,
            ),
          ),
        ),
      );

      expect(find.text('Room'), findsOneWidget);
      expect(find.text('21.4°C'), findsOneWidget);
      expect(find.text('Sensor'), findsOneWidget);
      expect(find.text('Estimated'), findsNothing);
    });

    testWidgets('shows the Estimated chip when isEstimated is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TemperatureReadingCard(
              label: 'Room',
              temperatureCelsius: 21.4,
              icon: Icons.home,
              isEstimated: true,
            ),
          ),
        ),
      );

      expect(find.text('Estimated'), findsOneWidget);
      expect(find.text('Sensor'), findsNothing);
    });

    testWidgets('converts to Fahrenheit when useFahrenheit is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TemperatureReadingCard(
              label: 'Outside',
              temperatureCelsius: 0,
              icon: Icons.cloud,
              useFahrenheit: true,
            ),
          ),
        ),
      );

      expect(find.text('32.0°F'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TemperatureReadingCard(
              label: 'Room',
              temperatureCelsius: 20,
              icon: Icons.home,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // The estimated/sensor chip renders its own nested InkWell, so target
      // the outermost one (the card's own tap target) specifically.
      await tester.tap(find.byType(InkWell).first);
      expect(tapped, isTrue);
    });
  });
}
