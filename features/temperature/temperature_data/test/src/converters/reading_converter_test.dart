import 'package:local_database/local_database.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ReadingConverter', () {
    const converter = ReadingConverter();

    test('fromRow maps every column onto the domain model', () {
      final row = ReadingRow(
        id: 7,
        roomTemperatureC: 22.5,
        roomTemperatureSource: 'ambientSensor',
        outsideTemperatureC: 18.25,
        recordedAt: DateTime.utc(2026, 3, 7, 9, 30),
      );

      final reading = converter.fromRow(row);

      expect(reading.roomTemperatureCelsius, 22.5);
      expect(reading.roomTemperatureSource, RoomTemperatureSource.ambientSensor);
      expect(reading.outsideTemperatureCelsius, 18.25);
      expect(reading.timestamp, DateTime.utc(2026, 3, 7, 9, 30));
      expect(reading.timestamp.isUtc, isTrue);
    });

    test('fromRow normalizes a local timestamp to UTC', () {
      final localTime = DateTime(2026, 3, 7, 9, 30);
      final row = ReadingRow(
        id: 1,
        roomTemperatureC: 20,
        roomTemperatureSource: 'estimated',
        outsideTemperatureC: 10,
        recordedAt: localTime,
      );

      expect(converter.fromRow(row).timestamp, localTime.toUtc());
    });

    test('sourceFromName resolves every RoomTemperatureSource', () {
      for (final source in RoomTemperatureSource.values) {
        expect(converter.sourceFromName(source.name), source);
      }
    });

    test('sourceFromName throws on an unknown name', () {
      expect(
        () => converter.sourceFromName('telepathy'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
