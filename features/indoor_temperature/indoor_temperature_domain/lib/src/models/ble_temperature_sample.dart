import 'package:equatable/equatable.dart';

/// {@template ble_temperature_sample}
/// One decoded temperature broadcast from a BLE sensor.
///
/// These sensors advertise their readings continuously, so a sample is
/// obtained by listening to advertisements rather than by connecting — no
/// pairing, no GATT session, and far less battery drain on the sensor.
/// {@endtemplate}
class BleTemperatureSample extends Equatable {
  /// {@macro ble_temperature_sample}
  const BleTemperatureSample({
    required this.deviceId,
    required this.celsius,
    this.humidityPercent,
    this.batteryPercent,
  });

  /// The id of the device that broadcast this sample.
  final String deviceId;

  /// The air temperature in Celsius. Unlike the phone's battery temperature,
  /// this is a genuine ambient measurement.
  final double celsius;

  /// Relative humidity as a percentage, when the sensor reports one.
  final double? humidityPercent;

  /// The sensor's remaining battery as a percentage, when it reports one.
  final int? batteryPercent;

  @override
  List<Object?> get props => [
    deviceId,
    celsius,
    humidityPercent,
    batteryPercent,
  ];
}
