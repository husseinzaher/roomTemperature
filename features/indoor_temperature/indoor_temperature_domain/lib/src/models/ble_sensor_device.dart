import 'package:equatable/equatable.dart';

/// {@template ble_sensor_device}
/// A Bluetooth Low Energy temperature sensor discovered during a scan.
/// {@endtemplate}
class BleSensorDevice extends Equatable {
  /// {@macro ble_sensor_device}
  const BleSensorDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });

  /// The platform's stable identifier for the device (its MAC address on
  /// Android). Persisted so a previously chosen sensor is recognised again.
  final String id;

  /// The advertised device name, or an empty string when it advertises none.
  final String name;

  /// Signal strength in dBm — closer to zero is stronger. Used to sort scan
  /// results so the nearest sensor is easiest to pick.
  final int rssi;

  @override
  List<Object?> get props => [id, name, rssi];
}
