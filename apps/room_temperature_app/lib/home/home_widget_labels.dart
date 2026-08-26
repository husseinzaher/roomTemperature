import 'package:temperature_domain/temperature_domain.dart';

/// Indoor-source label shown on the Android home and lock-screen widgets.
///
/// Matches the dashboard chip so the widget never calls battery temperature
/// "Room Temperature" or "Phone Sensor".
String homeWidgetSourceLabel(RoomTemperatureSource source) {
  return switch (source) {
    RoomTemperatureSource.ambientSensor => 'Phone Sensor',
    RoomTemperatureSource.bluetoothSensor => 'Bluetooth Sensor',
    RoomTemperatureSource.batteryTemperature => 'Battery Temperature',
    RoomTemperatureSource.manual => 'Manual',
    RoomTemperatureSource.estimated => 'Estimated',
  };
}
