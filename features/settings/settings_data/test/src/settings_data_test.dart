// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:settings_data/settings_data.dart';
import 'package:test/test.dart';

void main() {
  group('SettingsData', () {
    test('can be instantiated', () {
      expect(SettingsData(), isNotNull);
    });
  });
}
