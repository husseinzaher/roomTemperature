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

  // Some devices (and emulator images in particular) register a "virtual"
  // TYPE_AMBIENT_TEMPERATURE sensor that never fires a real event, or fires
  // one with an uninitialized/garbage value. Rather than trust any value a
  // sensor happens to report, only accept it if it falls within a generous
  // real-world ambient range — anything else is treated the same as "no
  // sensor" and the caller falls back to the weather-based estimate.
  static const ({double min, double max}) _plausibleRange = (
    min: -40,
    max: 60,
  );

  /// Returns the ambient temperature in Celsius, or `null` if the device
  /// has no ambient-temperature sensor, the read otherwise fails, or the
  /// reported value is outside a plausible ambient-temperature range.
  Future<double?> readCelsius() async {
    try {
      final result = await _channel.invokeMethod<double>(
        'getAmbientTemperature',
      );
      if (result == null ||
          result < _plausibleRange.min ||
          result > _plausibleRange.max) {
        return null;
      }
      return result;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
