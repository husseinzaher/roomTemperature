/// The user's selected indoor-temperature source mode.
///
/// [automatic] is a preference only; readings are still stored with the
/// concrete source that actually produced the value.
enum IndoorTemperaturePreference {
  /// Pick the first available source in priority order.
  automatic,

  /// Use Android's real ambient-temperature sensor.
  ambientSensor,

  /// Use an external Bluetooth temperature sensor.
  bluetoothSensor,

  /// Use the phone battery temperature. This is not room temperature.
  batteryTemperature,

  /// Use a user-entered indoor temperature.
  manual,

  /// Use a weather-derived estimate.
  estimated,
}
