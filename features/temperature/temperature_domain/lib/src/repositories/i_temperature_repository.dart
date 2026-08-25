import 'package:temperature_domain/src/models/reading.dart';

/// {@template i_temperature_repository}
/// Persists and streams a user's [Reading]s.
/// {@endtemplate}
abstract interface class ITemperatureRepository {
  /// Records a new [reading] for the user identified by [userId].
  Future<void> recordReading({
    required String userId,
    required Reading reading,
  });

  /// Watches the most recent [Reading] for the user identified by [userId].
  ///
  /// Emits `null` when the user has no readings yet.
  Stream<Reading?> watchLatestReading({required String userId});
}
