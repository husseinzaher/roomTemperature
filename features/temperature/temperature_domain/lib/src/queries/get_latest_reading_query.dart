import 'package:temperature_domain/src/models/reading.dart';
import 'package:temperature_domain/src/repositories/i_temperature_repository.dart';

/// {@template get_latest_reading_query}
/// Watches the latest [Reading] for a user via an [ITemperatureRepository].
/// {@endtemplate}
class GetLatestReadingQuery {
  /// {@macro get_latest_reading_query}
  const GetLatestReadingQuery({required this._temperatureRepository});

  final ITemperatureRepository _temperatureRepository;

  /// Watches the latest [Reading] for the user identified by [userId].
  Stream<Reading?> watch({required String userId}) {
    return _temperatureRepository.watchLatestReading(userId: userId);
  }
}
