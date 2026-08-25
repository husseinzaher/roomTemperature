import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    test('supports value equality', () {
      expect(
        const Location(latitude: 1, longitude: 2),
        const Location(latitude: 1, longitude: 2),
      );
      expect(
        const Location(latitude: 1, longitude: 2),
        isNot(const Location(latitude: 1, longitude: 3)),
      );
    });
  });

  group('Reading', () {
    final timestamp = DateTime(2026);

    test('supports value equality', () {
      final a = Reading(
        roomTemperatureCelsius: 22,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: 18,
        timestamp: timestamp,
      );
      final b = Reading(
        roomTemperatureCelsius: 22,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: 18,
        timestamp: timestamp,
      );

      expect(a, b);
    });

    test('isEstimated is true for RoomTemperatureSource.estimated', () {
      final reading = Reading(
        roomTemperatureCelsius: 22,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: 18,
        timestamp: timestamp,
      );

      expect(reading.isEstimated, isTrue);
    });

    test('isEstimated is false for RoomTemperatureSource.sensor', () {
      final reading = Reading(
        roomTemperatureCelsius: 22,
        roomTemperatureSource: RoomTemperatureSource.sensor,
        outsideTemperatureCelsius: 18,
        timestamp: timestamp,
      );

      expect(reading.isEstimated, isFalse);
    });
  });
}
