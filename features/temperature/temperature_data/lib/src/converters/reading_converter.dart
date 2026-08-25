import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temperature_data/src/sources/reading_dto.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template reading_converter}
/// Converts between the domain [Reading] model and the raw Firestore
/// document shape ([ReadingDto]).
///
/// Per FFCA data-layer guidance, this is the single place where Firestore's
/// raw map shape is translated to and from the domain model — no other
/// class in this package or above should touch a raw Firestore map for a
/// reading.
/// {@endtemplate}
class ReadingConverter {
  /// {@macro reading_converter}
  const ReadingConverter();

  /// Converts a raw Firestore document [data] map to a domain [Reading].
  Reading fromFirestore(Map<String, dynamic> data) {
    final dto = ReadingDto.fromMap(data);

    return Reading(
      roomTemperatureCelsius: dto.roomTemperatureC,
      roomTemperatureSource: _sourceFromString(dto.roomTemperatureSource),
      outsideTemperatureCelsius: dto.outsideTemperatureC,
      // Timestamp.toDate() always returns local time; normalize back to UTC
      // so round-tripped readings compare equal regardless of the host's
      // timezone.
      timestamp: dto.timestamp.toDate().toUtc(),
    );
  }

  /// Converts a domain [Reading] to a raw Firestore document map.
  Map<String, dynamic> toFirestore(Reading reading) {
    final dto = ReadingDto(
      roomTemperatureC: reading.roomTemperatureCelsius,
      roomTemperatureSource: _sourceToString(reading.roomTemperatureSource),
      outsideTemperatureC: reading.outsideTemperatureCelsius,
      timestamp: Timestamp.fromDate(reading.timestamp),
    );

    return dto.toMap();
  }

  RoomTemperatureSource _sourceFromString(String value) => switch (value) {
    'sensor' => RoomTemperatureSource.sensor,
    'estimated' => RoomTemperatureSource.estimated,
    _ => throw FormatException('Unknown roomTemperatureSource: $value'),
  };

  String _sourceToString(RoomTemperatureSource source) => switch (source) {
    RoomTemperatureSource.sensor => 'sensor',
    RoomTemperatureSource.estimated => 'estimated',
  };
}
