// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:auth_data/auth_data.dart';
import 'package:test/test.dart';

void main() {
  group('AuthData', () {
    test('can be instantiated', () {
      expect(AuthData(), isNotNull);
    });
  });
}
