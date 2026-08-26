import 'package:local_database/local_database.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template reading_converter}
/// Converts a Drift [ReadingRow] into the domain [Reading] model.
///
/// This is the boundary that keeps the generated Drift row types inside this
/// package: nothing above the data layer ever sees a [ReadingRow].
/// {@endtemplate}
class ReadingConverter {
  /// {@macro reading_converter}
  const ReadingConverter();

  /// Converts a stored [row] into a domain [Reading].
  ///
  /// Throws a [FormatException] when the stored source name matches no
  /// [RoomTemperatureSource] value — a row written by a newer build of the
  /// app is a bug worth surfacing, not something to silently coerce.
  Reading fromRow(ReadingRow row) {
    return Reading(
      roomTemperatureCelsius: row.roomTemperatureC,
      roomTemperatureSource: sourceFromName(row.roomTemperatureSource),
      outsideTemperatureCelsius: row.outsideTemperatureC,
      timestamp: row.recordedAt.toUtc(),
    );
  }

  /// Resolves the [RoomTemperatureSource] stored under [name].
  RoomTemperatureSource sourceFromName(String name) {
    for (final source in RoomTemperatureSource.values) {
      if (source.name == name) return source;
    }
    throw FormatException('Unknown roomTemperatureSource: $name');
  }
}
