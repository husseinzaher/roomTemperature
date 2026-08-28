import 'package:geolocator/geolocator.dart';
import 'package:room_temperature_app/places/place_history_repository.dart';
import 'package:room_temperature_app/services/location_service.dart';
import 'package:settings_domain/settings_domain.dart';

/// {@template place_visit_tracker}
/// Samples visits on the existing refresh/sample cadence.
///
/// Uses last-known location only — no high-frequency GPS loop. Indoor
/// temperature is the caller-supplied estimator output, never battery °C.
/// {@endtemplate}
class PlaceVisitTracker {
  /// {@macro place_visit_tracker}
  const PlaceVisitTracker({
    required this.repository,
    required this.locationService,
  });

  /// Local visit store.
  final PlaceHistoryRepository repository;

  /// Permission + last-known location. Never requests a dialog here.
  final LocationService locationService;

  /// Records one sample when place history is enabled and permission exists.
  Future<void> observe({
    required UserSettings settings,
    required double? indoorCelsius,
    DateTime? at,
  }) async {
    if (!settings.placeHistoryEnabled) {
      return;
    }
    try {
      final permission = await locationService.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      if (!await locationService.isServiceEnabled()) {
        return;
      }
      final location = await locationService.lastKnownOrNull();
      if (location == null) {
        return;
      }
      await repository.observe(
        enabled: true,
        latitude: location.latitude,
        longitude: location.longitude,
        at: at ?? DateTime.now(),
        indoorCelsius: indoorCelsius,
      );
    } on Exception {
      // Place history must never fail indoor refresh or widgets.
    }
  }

  /// Closes an in-progress visit when the user disables tracking.
  Future<void> stopTracking() async {
    try {
      await repository.stopTracking();
    } on Exception {
      // Best-effort close.
    }
  }
}
