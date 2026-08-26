import 'package:temperature_domain/src/models/reading.dart';
import 'package:temperature_domain/src/repositories/i_temperature_repository.dart';

/// {@template get_latest_reading_query}
/// Watches the latest [Reading] via an [ITemperatureRepository].
/// {@endtemplate}
class GetLatestReadingQuery {
  /// {@macro get_latest_reading_query}
  const GetLatestReadingQuery({required this._temperatureRepository});

  final ITemperatureRepository _temperatureRepository;

  /// Watches the latest [Reading].
  Stream<Reading?> watch() {
    return _temperatureRepository.watchLatestReading();
  }
}
