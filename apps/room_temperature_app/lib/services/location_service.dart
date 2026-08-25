import 'package:geolocator/geolocator.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template location_service}
/// Resolves the device's current location for outside-weather lookups,
/// requesting location permission if needed.
/// {@endtemplate}
class LocationService {
  /// {@macro location_service}
  const LocationService();

  /// Returns the device's current [Location], requesting permission first
  /// if it hasn't been granted yet. Falls back to the last known position
  /// when a fresh fix can't be obtained quickly.
  Future<Location> getCurrentLocation() async {
    final permission = await _ensurePermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on Exception {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return Location(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
        );
      }
      rethrow;
    }
  }

  Future<LocationPermission> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }
}

/// Thrown when the user has denied location permission, so the app can't
/// look up outside weather for their position.
class LocationPermissionDeniedException implements Exception {
  /// Creates a [LocationPermissionDeniedException].
  const LocationPermissionDeniedException();

  @override
  String toString() => 'Location permission was denied.';
}
