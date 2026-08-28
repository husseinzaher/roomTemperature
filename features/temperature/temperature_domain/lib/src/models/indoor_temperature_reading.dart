import 'package:temperature_domain/src/indoor_estimator/indoor_estimator_models.dart';
import 'package:temperature_domain/src/models/room_temperature_source.dart';

/// A temperature value and the concrete source that produced it.
class IndoorTemperatureReading {
  /// Creates an indoor-temperature reading.
  const IndoorTemperatureReading({
    required this.celsius,
    required this.source,
    this.confidence = 1,
    this.calibrationApplied = false,
    this.debug,
  });

  /// The temperature value in Celsius.
  final double celsius;

  /// The concrete source that produced [celsius].
  final IndoorTemperatureSource source;

  /// 0–1 confidence. Direct sensors default to 1.
  final double confidence;

  /// Whether a local calibration profile was applied.
  final bool calibrationApplied;

  /// Estimator debug dump, when this reading came from the local estimator.
  final IndoorEstimateDebug? debug;

  /// Temperature rounded for display according to [confidence].
  double get displayCelsius {
    if (confidence >= 0.7) {
      return (celsius * 10).round() / 10;
    }
    return celsius.roundToDouble();
  }

  /// Whether the UI should prefix the value with ≈.
  bool get isApproximate => confidence < 0.45;
}
