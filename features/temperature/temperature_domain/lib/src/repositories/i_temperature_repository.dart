import 'package:temperature_domain/src/models/reading.dart';

/// {@template i_temperature_repository}
/// Persists and streams this device's [Reading]s.
/// {@endtemplate}
abstract interface class ITemperatureRepository {
  /// Records a new [reading].
  Future<void> recordReading({required Reading reading});

  /// Watches the most recent [Reading].
  ///
  /// Emits `null` when nothing has been recorded yet.
  Stream<Reading?> watchLatestReading();
}
