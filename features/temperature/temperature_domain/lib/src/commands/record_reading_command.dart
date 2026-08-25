import 'package:temperature_domain/src/models/reading.dart';
import 'package:temperature_domain/src/repositories/i_temperature_repository.dart';

/// {@template record_reading_command}
/// Records a [Reading] for a user via an [ITemperatureRepository].
/// {@endtemplate}
class RecordReadingCommand {
  /// {@macro record_reading_command}
  const RecordReadingCommand({required this._temperatureRepository});

  final ITemperatureRepository _temperatureRepository;

  /// Records [reading] for the user identified by [userId].
  Future<void> execute({required String userId, required Reading reading}) {
    return _temperatureRepository.recordReading(
      userId: userId,
      reading: reading,
    );
  }
}
