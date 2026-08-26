import 'package:indoor_temperature_domain/src/models/ble_sensor_device.dart';
import 'package:indoor_temperature_domain/src/models/ble_temperature_sample.dart';

/// Why a BLE scan or read could not be performed.
enum BleUnavailableReason {
  /// The device has no Bluetooth hardware, or it isn't supported.
  unsupported,

  /// Bluetooth is switched off.
  bluetoothOff,

  /// The user declined the Bluetooth (or, on older Android, location)
  /// permissions a scan requires.
  permissionDenied,
}

/// Thrown when BLE cannot be used, carrying the specific [reason] so the UI
/// can tell the user what to fix rather than showing a generic failure.
class BleUnavailableException implements Exception {
  /// Creates a [BleUnavailableException].
  const BleUnavailableException(this.reason);

  /// Why BLE is unavailable.
  final BleUnavailableReason reason;

  @override
  String toString() => 'BleUnavailableException: ${reason.name}';
}

/// {@template i_ble_temperature_repository}
/// Discovers BLE temperature sensors and streams their readings.
/// {@endtemplate}
abstract interface class IBleTemperatureRepository {
  /// Whether BLE is usable right now: hardware present, adapter on, and the
  /// required permissions granted.
  Future<bool> isAvailable();

  /// Scans for supported temperature sensors for [timeout], emitting the
  /// running list of discoveries so the UI can populate as results arrive.
  ///
  /// Throws [BleUnavailableException] when BLE can't be used.
  Stream<List<BleSensorDevice>> scanForSensors({
    Duration timeout = const Duration(seconds: 10),
  });

  /// Streams decoded samples broadcast by the sensor with [deviceId].
  ///
  /// Throws [BleUnavailableException] when BLE can't be used.
  Stream<BleTemperatureSample> watchSensor({required String deviceId});

  /// Reads a single sample from [deviceId], giving up after [timeout].
  ///
  /// Returns null if the sensor broadcast nothing in time.
  Future<BleTemperatureSample?> readOnce({
    required String deviceId,
    Duration timeout = const Duration(seconds: 8),
  });
}
