import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/splash/splash_page.dart';

import '../helpers/pump_app.dart';

void main() {
  group('SplashPage', () {
    testWidgets('renders a progress indicator', (tester) async {
      await tester.pumpApp(const SplashPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
