import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ReadingConverter', () {
    const converter = ReadingConverter();

    test(
      'round-trips an estimated reading through toMap/fromMap',
      () {
        final reading = Reading(
          roomTemperatureCelsius: 24.5,
          roomTemperatureSource: RoomTemperatureSource.estimated,
          outsideTemperatureCelsius: 21,
          timestamp: DateTime.utc(2026, 1, 1, 12),
        );

        final map = converter.toMap(reading);
        final result = converter.fromMap(map);

        expect(result, reading);
      },
    );

    test('round-trips a battery reading through toMap/fromMap', () {
      final reading = Reading(
        roomTemperatureCelsius: 36.5,
        roomTemperatureSource: RoomTemperatureSource.batteryTemperature,
        outsideTemperatureCelsius: 21,
        timestamp: DateTime.utc(2026, 1, 1, 12),
      );

      final result = converter.fromMap(converter.toMap(reading));

      expect(result, reading);
      expect(
        converter.toMap(reading)['roomTemperatureSource'],
        'batteryTemperature',
      );
    });

    test('round-trips an ambient reading through toMap/fromMap', () {
      final reading = Reading(
        roomTemperatureCelsius: 23,
        roomTemperatureSource: RoomTemperatureSource.ambientSensor,
        outsideTemperatureCelsius: 19.2,
        timestamp: DateTime.utc(2026, 6, 15, 8, 30),
      );

      final map = converter.toMap(reading);
      final result = converter.fromMap(map);

      expect(result, reading);
    });

    test('toMap writes the expected map shape', () {
      final reading = Reading(
        roomTemperatureCelsius: 24.5,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: 21,
        timestamp: DateTime.utc(2026, 1, 1, 12),
      );

      final map = converter.toMap(reading);

      expect(map['roomTemperatureC'], 24.5);
      expect(map['roomTemperatureSource'], 'estimated');
      expect(map['outsideTemperatureC'], 21);
      expect(map['timestamp'], '2026-01-01T12:00:00.000Z');
    });

    test('fromMap parses the legacy sensor source string as ambient', () {
      final map = {
        'roomTemperatureC': 22.0,
        'roomTemperatureSource': 'sensor',
        'outsideTemperatureC': 18.0,
        'timestamp': DateTime.utc(2026).toIso8601String(),
      };

      final result = converter.fromMap(map);

      expect(result.roomTemperatureSource, RoomTemperatureSource.ambientSensor);
      expect(result.isEstimated, isFalse);
    });

    test('fromMap throws on an unknown source string', () {
      final map = {
        'roomTemperatureC': 22.0,
        'roomTemperatureSource': 'bogus',
        'outsideTemperatureC': 18.0,
        'timestamp': DateTime.utc(2026).toIso8601String(),
      };

      expect(() => converter.fromMap(map), throwsFormatException);
    });
  });
}
