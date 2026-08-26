import 'package:equatable/equatable.dart';

/// {@template ble_advertisement}
/// The parts of a BLE advertisement that temperature sensors encode their
/// readings into, lifted out of any particular Bluetooth plugin's types.
///
/// Keeping this plugin-agnostic is what lets the decoders be plain pure
/// functions with byte-vector unit tests — no Bluetooth adapter, no device,
/// and no platform channel needed to prove the maths is right.
/// {@endtemplate}
class BleAdvertisement extends Equatable {
  /// {@macro ble_advertisement}
  const BleAdvertisement({
    required this.deviceId,
    required this.name,
    this.manufacturerData = const {},
    this.serviceData = const {},
  });

  /// The advertising device's stable id.
  final String deviceId;

  /// The advertised local name, or an empty string.
  final String name;

  /// Manufacturer-specific data, keyed by the 16-bit company identifier.
  /// The bytes exclude the company id itself.
  final Map<int, List<int>> manufacturerData;

  /// Service data, keyed by the 16-bit service UUID. The bytes exclude the
  /// UUID itself.
  final Map<int, List<int>> serviceData;

  @override
  List<Object?> get props => [deviceId, name, manufacturerData, serviceData];
}
