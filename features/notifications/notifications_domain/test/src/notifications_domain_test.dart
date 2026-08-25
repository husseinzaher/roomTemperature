// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:notifications_domain/notifications_domain.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationsDomain', () {
    test('can be instantiated', () {
      expect(NotificationsDomain(), isNotNull);
    });
  });
}
