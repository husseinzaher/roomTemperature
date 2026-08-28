import 'package:local_database/local_database.dart';
import 'package:temperature_data/src/converters/reading_converter.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template drift_temperature_repository}
/// An [ITemperatureRepository] backed by the on-device Drift database.
///
/// Readings are appended to a time series rather than overwriting a single
/// "latest" record, so history and future trend features can read back every
/// sample that was ever taken.
/// {@endtemplate}
class DriftTemperatureRepository implements ITemperatureRepository {
  /// {@macro drift_temperature_repository}
  const DriftTemperatureRepository({
    required AppDatabase database,
    ReadingConverter converter = const ReadingConverter(),
  }) : _database = database,
       _converter = converter;

  final AppDatabase _database;
  final ReadingConverter _converter;

  @override
  Future<void> recordReading({required Reading reading}) {
    final outside = reading.outsideTemperatureCelsius;
    if (outside == null) {
      return Future.value();
    }
    return _database.insertReading(
      roomTemperatureC: reading.roomTemperatureCelsius,
      roomTemperatureSource: reading.roomTemperatureSource.name,
      outsideTemperatureC: outside,
      recordedAt: reading.timestamp,
    );
  }

  @override
  Stream<Reading?> watchLatestReading() {
    return _database.watchLatestReading().map(
      (row) => row == null ? null : _converter.fromRow(row),
    );
  }
}
