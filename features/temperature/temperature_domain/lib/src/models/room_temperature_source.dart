/// The source that produced the displayed indoor temperature value.
enum IndoorTemperatureSource {
  /// A real Android ambient-temperature sensor
  /// (`Sensor.TYPE_AMBIENT_TEMPERATURE`).
  ambientSensor,

  /// An external Bluetooth temperature sensor.
  bluetoothSensor,

  /// The phone battery temperature. This is a device measurement, not an
  /// actual ambient room measurement.
  batteryTemperature,

  /// A user-entered indoor temperature.
  manual,

  /// A weather-derived estimate.
  estimated,
}

/// Backwards-compatible name used by the existing reading model.
typedef RoomTemperatureSource = IndoorTemperatureSource;
