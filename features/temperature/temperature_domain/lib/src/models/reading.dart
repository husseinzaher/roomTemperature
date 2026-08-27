import 'package:equatable/equatable.dart';
import 'package:temperature_domain/src/models/room_temperature_source.dart';

/// {@template reading}
/// A single point-in-time reading combining a room temperature (real sensor
/// or estimated) and the real outside temperature it was derived from.
/// {@endtemplate}
class Reading extends Equatable {
  /// {@macro reading}
  const Reading({
    required this.roomTemperatureCelsius,
    required this.roomTemperatureSource,
    required this.outsideTemperatureCelsius,
    required this.timestamp,
    this.indoorConfidence,
  });

  /// The room temperature in Celsius. This is either a real sensor reading
  /// or an estimate derived from the outside temperature and an indoor
  /// offset — see [roomTemperatureSource].
  final double roomTemperatureCelsius;

  /// Where [roomTemperatureCelsius] came from.
  final RoomTemperatureSource roomTemperatureSource;

  /// The real outside temperature in Celsius, fetched from a weather API.
  ///
  /// `null` when indoor was resolved locally and no outside reading is known
  /// yet (airplane mode on a fresh install).
  final double? outsideTemperatureCelsius;

  /// When this reading was taken.
  final DateTime timestamp;

  /// Live indoor-estimate confidence. `null` for cached rows (not persisted).
  final double? indoorConfidence;

  /// Whether the room temperature is an estimate rather than a direct
  /// sensor reading. The UI must clearly label estimated readings as such.
  bool get isEstimated =>
      roomTemperatureSource == RoomTemperatureSource.estimated;

  @override
  List<Object?> get props => [
    roomTemperatureCelsius,
    roomTemperatureSource,
    outsideTemperatureCelsius,
    timestamp,
    indoorConfidence,
  ];
}
