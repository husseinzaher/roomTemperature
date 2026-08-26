import 'package:flutter/services.dart';

/// Reads Android battery temperature in Celsius.
///
/// Android exposes `BatteryManager.EXTRA_TEMPERATURE` in tenths of a degree
/// Celsius (`365` → `36.5 °C`). Conversion happens natively and is also
/// applied defensively here so a raw tenths value can never reach the UI.
class BatteryTemperatureService {
  /// Creates a battery temperature service.
  const BatteryTemperatureService();

  static const _channel = MethodChannel(
    'room_temperature/battery_temperature',
  );

  static const ({double min, double max}) _plausibleRange = (
    min: -20,
    max: 90,
  );

  /// Converts a raw Android battery temperature to Celsius.
  ///
  /// Values already in Celsius (typical battery range) are left as-is.
  /// Values whose magnitude is 100 or more are treated as tenths of a
  /// degree (`365` → `36.5`).
  static double celsiusFromRaw(num raw) {
    final value = raw.toDouble();
    if (value.abs() >= 100) {
      return value / 10;
    }
    return value;
  }

  /// Returns whether the platform exposes a battery temperature.
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('hasBatteryTemperature') ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns the current battery temperature in Celsius, or `null` when the
  /// platform does not expose one.
  Future<double?> readCelsius() async {
    try {
      final result = await _channel.invokeMethod<num>('getBatteryTemperature');
      if (result == null) return null;
      final celsius = celsiusFromRaw(result);
      if (celsius < _plausibleRange.min || celsius > _plausibleRange.max) {
        return null;
      }
      return celsius;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
