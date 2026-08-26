import 'package:temperature_domain/src/models/reading.dart';
import 'package:temperature_domain/src/repositories/i_temperature_repository.dart';

/// {@template record_reading_command}
/// Records a [Reading] via an [ITemperatureRepository].
/// {@endtemplate}
class RecordReadingCommand {
  /// {@macro record_reading_command}
  const RecordReadingCommand({required this._temperatureRepository});

  final ITemperatureRepository _temperatureRepository;

  /// Records [reading].
  Future<void> execute({required Reading reading}) {
    return _temperatureRepository.recordReading(reading: reading);
  }
}
