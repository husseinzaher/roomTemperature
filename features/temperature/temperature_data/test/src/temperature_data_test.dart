// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:temperature_data/temperature_data.dart';
import 'package:test/test.dart';

void main() {
  group('TemperatureData', () {
    test('can be instantiated', () {
      expect(TemperatureData(), isNotNull);
    });
  });
}
