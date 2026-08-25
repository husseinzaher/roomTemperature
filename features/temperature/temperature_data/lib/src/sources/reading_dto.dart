import 'package:cloud_firestore/cloud_firestore.dart';

/// {@template reading_dto}
/// The raw Firestore document shape for a reading, under
/// `users/{userId}/readings/{autoId}`.
///
/// This DTO keeps Firestore's raw map shape from ever escaping the data
/// layer — see ReadingConverter in `converters/reading_converter.dart`.
/// {@endtemplate}
class ReadingDto {
  /// {@macro reading_dto}
  const ReadingDto({
    required this.roomTemperatureC,
    required this.roomTemperatureSource,
    required this.outsideTemperatureC,
    required this.timestamp,
  });

  /// Builds a [ReadingDto] from a raw Firestore document map.
  ReadingDto.fromMap(Map<String, dynamic> map)
    : roomTemperatureC = (map['roomTemperatureC'] as num).toDouble(),
      roomTemperatureSource = map['roomTemperatureSource'] as String,
      outsideTemperatureC = (map['outsideTemperatureC'] as num).toDouble(),
      timestamp = map['timestamp'] as Timestamp;

  /// The room temperature in Celsius.
  final double roomTemperatureC;

  /// Either `'estimated'` or `'sensor'`.
  final String roomTemperatureSource;

  /// The real outside temperature in Celsius.
  final double outsideTemperatureC;

  /// When the reading was taken.
  final Timestamp timestamp;

  /// Converts this DTO to a raw Firestore document map.
  Map<String, dynamic> toMap() => {
    'roomTemperatureC': roomTemperatureC,
    'roomTemperatureSource': roomTemperatureSource,
    'outsideTemperatureC': outsideTemperatureC,
    'timestamp': timestamp,
  };
}
