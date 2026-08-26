import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/splash/splash_page.dart';

import '../helpers/pump_app.dart';

void main() {
  group('SplashPage', () {
    testWidgets('renders the app logo instead of a template icon', (
      tester,
    ) async {
      await tester.pumpApp(const SplashPage());

      expect(find.byKey(const Key('app_logo')), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
      expect(find.byIcon(Icons.thermostat), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('calls onFinished after the intro animation', (tester) async {
      var finished = false;

      await tester.pumpApp(
        SplashPage(onFinished: () => finished = true),
      );

      expect(finished, isFalse);

      await tester.pump(
        SplashPage.introDuration + const Duration(milliseconds: 50),
      );
      await tester.pump();

      expect(finished, isTrue);
    });
  });
}
