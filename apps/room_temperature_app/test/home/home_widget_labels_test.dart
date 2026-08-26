import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/home/home_widget_labels.dart';
import 'package:temperature_domain/temperature_domain.dart';

void main() {
  group('homeWidgetSourceLabel', () {
    test('labels each indoor source the same way as the dashboard', () {
      expect(
        homeWidgetSourceLabel(RoomTemperatureSource.ambientSensor),
        'Phone Sensor',
      );
      expect(
        homeWidgetSourceLabel(RoomTemperatureSource.bluetoothSensor),
        'Bluetooth Sensor',
      );
      expect(
        homeWidgetSourceLabel(RoomTemperatureSource.batteryTemperature),
        'Battery Temperature',
      );
      expect(
        homeWidgetSourceLabel(RoomTemperatureSource.manual),
        'Manual',
      );
      expect(
        homeWidgetSourceLabel(RoomTemperatureSource.estimated),
        'Estimated',
      );
    });
  });
}
