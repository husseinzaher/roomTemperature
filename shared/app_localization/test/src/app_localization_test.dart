// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:app_localization/app_localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalization', () {
    test('can be instantiated', () {
      expect(AppLocalization(), isNotNull);
    });
  });
}
