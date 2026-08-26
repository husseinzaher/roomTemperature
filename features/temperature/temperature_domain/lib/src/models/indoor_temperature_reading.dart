import 'package:temperature_domain/src/models/room_temperature_source.dart';

/// A temperature value and the concrete source that produced it.
class IndoorTemperatureReading {
  /// Creates an indoor-temperature reading.
  const IndoorTemperatureReading({
    required this.celsius,
    required this.source,
  });

  /// The temperature value in Celsius.
  final double celsius;

  /// The concrete source that produced [celsius].
  final IndoorTemperatureSource source;
}
