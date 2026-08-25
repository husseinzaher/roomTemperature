// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:auth_domain/auth_domain.dart';
import 'package:test/test.dart';

void main() {
  group('AuthDomain', () {
    test('can be instantiated', () {
      expect(AuthDomain(), isNotNull);
    });
  });
}
