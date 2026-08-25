import 'package:flutter/services.dart';

/// {@template ambient_sensor_service}
/// Reads the device's built-in ambient-temperature sensor
/// (`Sensor.TYPE_AMBIENT_TEMPERATURE` on Android), when the device has one.
///
/// Most phones don't expose this sensor at all, so [readCelsius] returning
/// `null` is the expected, common case — callers should fall back to the
/// weather-based room-temperature estimate when that happens.
/// {@endtemplate}
class AmbientSensorService {
  /// {@macro ambient_sensor_service}
  const AmbientSensorService();

  static const _channel = MethodChannel('room_temperature/ambient_sensor');

  /// Returns the ambient temperature in Celsius, or `null` if the device
  /// has no ambient-temperature sensor (or the read otherwise fails).
  Future<double?> readCelsius() async {
    try {
      final result = await _channel.invokeMethod<double>(
        'getAmbientTemperature',
      );
      return result;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
