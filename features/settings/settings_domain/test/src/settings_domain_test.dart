// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

void main() {
  group('SettingsDomain', () {
    test('can be instantiated', () {
      expect(SettingsDomain(), isNotNull);
    });
  });
}
