import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ReadingConverter', () {
    const converter = ReadingConverter();

    test(
      'round-trips an estimated reading through toFirestore/fromFirestore',
      () {
        final reading = Reading(
          roomTemperatureCelsius: 24.5,
          roomTemperatureSource: RoomTemperatureSource.estimated,
          outsideTemperatureCelsius: 21,
          timestamp: DateTime.utc(2026, 1, 1, 12),
        );

        final map = converter.toFirestore(reading);
        final result = converter.fromFirestore(map);

        expect(result, reading);
      },
    );

    test('round-trips a sensor reading through toFirestore/fromFirestore', () {
      final reading = Reading(
        roomTemperatureCelsius: 23,
        roomTemperatureSource: RoomTemperatureSource.sensor,
        outsideTemperatureCelsius: 19.2,
        timestamp: DateTime.utc(2026, 6, 15, 8, 30),
      );

      final map = converter.toFirestore(reading);
      final result = converter.fromFirestore(map);

      expect(result, reading);
    });

    test('toFirestore writes the expected map shape', () {
      final reading = Reading(
        roomTemperatureCelsius: 24.5,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: 21,
        timestamp: DateTime.utc(2026, 1, 1, 12),
      );

      final map = converter.toFirestore(reading);

      expect(map['roomTemperatureC'], 24.5);
      expect(map['roomTemperatureSource'], 'estimated');
      expect(map['outsideTemperatureC'], 21);
      expect(map['timestamp'], isA<Timestamp>());
    });

    test('fromFirestore parses a sensor source string', () {
      final map = {
        'roomTemperatureC': 22.0,
        'roomTemperatureSource': 'sensor',
        'outsideTemperatureC': 18.0,
        'timestamp': Timestamp.fromDate(DateTime.utc(2026)),
      };

      final result = converter.fromFirestore(map);

      expect(result.roomTemperatureSource, RoomTemperatureSource.sensor);
      expect(result.isEstimated, isFalse);
    });

    test('fromFirestore throws on an unknown source string', () {
      final map = {
        'roomTemperatureC': 22.0,
        'roomTemperatureSource': 'bogus',
        'outsideTemperatureC': 18.0,
        'timestamp': Timestamp.fromDate(DateTime.utc(2026)),
      };

      expect(() => converter.fromFirestore(map), throwsFormatException);
    });
  });
}
