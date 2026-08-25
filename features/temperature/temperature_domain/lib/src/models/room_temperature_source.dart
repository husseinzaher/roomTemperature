/// The source that produced a room temperature value.
enum RoomTemperatureSource {
  /// The room temperature was estimated from the outside temperature plus
  /// a user-adjustable indoor offset. There is no real ambient sensor.
  estimated,

  /// The room temperature came from a real ambient sensor reading.
  sensor,
}
