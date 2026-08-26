import 'package:temperature_domain/temperature_domain.dart';

/// {@template reading_converter}
/// Converts between the domain [Reading] model and the local JSON map shape.
/// {@endtemplate}
class ReadingConverter {
  /// {@macro reading_converter}
  const ReadingConverter();

  /// Converts a raw local [data] map to a domain [Reading].
  Reading fromMap(Map<String, dynamic> data) {
    return Reading(
      roomTemperatureCelsius: (data['roomTemperatureC'] as num).toDouble(),
      roomTemperatureSource: _sourceFromString(
        data['roomTemperatureSource'] as String,
      ),
      outsideTemperatureCelsius: (data['outsideTemperatureC'] as num)
          .toDouble(),
      timestamp: DateTime.parse(data['timestamp'] as String).toUtc(),
    );
  }

  /// Converts a domain [Reading] to a local JSON map.
  Map<String, dynamic> toMap(Reading reading) => {
    'roomTemperatureC': reading.roomTemperatureCelsius,
    'roomTemperatureSource': _sourceToString(reading.roomTemperatureSource),
    'outsideTemperatureC': reading.outsideTemperatureCelsius,
    'timestamp': reading.timestamp.toUtc().toIso8601String(),
  };

  RoomTemperatureSource _sourceFromString(String value) => switch (value) {
    'ambientSensor' => RoomTemperatureSource.ambientSensor,
    'sensor' => RoomTemperatureSource.ambientSensor,
    'bluetoothSensor' => RoomTemperatureSource.bluetoothSensor,
    'batteryTemperature' => RoomTemperatureSource.batteryTemperature,
    'manual' => RoomTemperatureSource.manual,
    'estimated' => RoomTemperatureSource.estimated,
    _ => throw FormatException('Unknown roomTemperatureSource: $value'),
  };

  String _sourceToString(RoomTemperatureSource source) => switch (source) {
    RoomTemperatureSource.ambientSensor => 'ambientSensor',
    RoomTemperatureSource.bluetoothSensor => 'bluetoothSensor',
    RoomTemperatureSource.batteryTemperature => 'batteryTemperature',
    RoomTemperatureSource.manual => 'manual',
    RoomTemperatureSource.estimated => 'estimated',
  };
}
