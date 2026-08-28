import 'package:flutter/services.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// Reads a local thermal snapshot from Android. Never touches the network.
class ThermalDataService {
  /// Creates a thermal data service.
  const ThermalDataService();

  static const _channel = MethodChannel('room_temperature/thermal_data');

  /// Returns the current device thermal snapshot, or `null` when unavailable.
  Future<ThermalSnapshot?> readSnapshot() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>(
        'getThermalSnapshot',
      );
      if (raw is! Map) {
        return null;
      }
      return ThermalSnapshot.fromJson(Map<String, dynamic>.from(raw));
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
