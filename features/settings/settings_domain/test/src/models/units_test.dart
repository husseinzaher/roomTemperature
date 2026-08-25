import 'package:settings_domain/settings_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Units', () {
    test('celsius symbol is °C', () {
      expect(Units.celsius.symbol, '°C');
    });

    test('fahrenheit symbol is °F', () {
      expect(Units.fahrenheit.symbol, '°F');
    });

    test('celsius fromCelsius is the identity', () {
      expect(Units.celsius.fromCelsius(20), 20);
      expect(Units.celsius.fromCelsius(-5), -5);
    });

    test('fahrenheit fromCelsius converts using c * 9/5 + 32', () {
      expect(Units.fahrenheit.fromCelsius(0), 32);
      expect(Units.fahrenheit.fromCelsius(100), 212);
      expect(Units.fahrenheit.fromCelsius(20), closeTo(68, 1e-9));
    });
  });
}
