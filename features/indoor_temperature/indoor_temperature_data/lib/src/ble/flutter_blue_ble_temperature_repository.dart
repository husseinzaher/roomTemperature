import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:indoor_temperature_data/src/ble/ble_temperature_decoder.dart';
import 'package:indoor_temperature_domain/indoor_temperature_domain.dart';
import 'package:permission_handler/permission_handler.dart';

/// {@template flutter_blue_ble_temperature_repository}
/// Reads BLE temperature sensors by listening to their advertisements.
///
/// Supported sensors broadcast their readings continuously, so this never
/// connects or pairs: it scans, decodes the advertisement payload, and
/// stops. That keeps the sensor's coin cell alive for months and avoids the
/// whole GATT connection lifecycle.
/// {@endtemplate}
class FlutterBlueBleTemperatureRepository implements IBleTemperatureRepository {
  /// {@macro flutter_blue_ble_temperature_repository}
  FlutterBlueBleTemperatureRepository();

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await FlutterBluePlus.isSupported) return false;
      if (!await _ensurePermissions()) return false;
      return FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on;
    } on Exception {
      return false;
    }
  }

  @override
  Stream<List<BleSensorDevice>> scanForSensors({
    Duration timeout = const Duration(seconds: 10),
  }) async* {
    await _guardAvailable();

    // Keyed by device id so a sensor re-advertising during the scan updates
    // its signal strength in place instead of appearing twice.
    final discovered = <String, BleSensorDevice>{};
    final controller = StreamController<List<BleSensorDevice>>();

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      var changed = false;
      for (final result in results) {
        final advertisement = _toAdvertisement(result);
        if (!BleTemperatureDecoder.isSupportedSensor(advertisement)) continue;

        final device = BleSensorDevice(
          id: advertisement.deviceId,
          name: advertisement.name,
          rssi: result.rssi,
        );
        if (discovered[device.id] != device) {
          discovered[device.id] = device;
          changed = true;
        }
      }
      if (changed && !controller.isClosed) {
        final sorted = discovered.values.toList()
          ..sort((a, b) => b.rssi.compareTo(a.rssi));
        controller.add(sorted);
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: timeout);
      yield* controller.stream;
    } finally {
      await subscription.cancel();
      await controller.close();
      await FlutterBluePlus.stopScan();
    }
  }

  @override
  Stream<BleTemperatureSample> watchSensor({required String deviceId}) async* {
    await _guardAvailable();

    final controller = StreamController<BleTemperatureSample>();

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final advertisement = _toAdvertisement(result);
        if (advertisement.deviceId != deviceId) continue;

        final sample = BleTemperatureDecoder.decode(advertisement);
        if (sample != null && !controller.isClosed) {
          controller.add(sample);
        }
      }
    });

    try {
      // No timeout: the caller decides how long to listen, and continuous
      // scanning is what keeps a live reading up to date.
      await FlutterBluePlus.startScan(continuousUpdates: true);
      yield* controller.stream;
    } finally {
      await subscription.cancel();
      await controller.close();
      await FlutterBluePlus.stopScan();
    }
  }

  @override
  Future<BleTemperatureSample?> readOnce({
    required String deviceId,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      return await watchSensor(deviceId: deviceId).first.timeout(timeout);
    } on TimeoutException {
      return null;
    } on BleUnavailableException {
      rethrow;
    } on Exception {
      return null;
    }
  }

  Future<void> _guardAvailable() async {
    if (!await FlutterBluePlus.isSupported) {
      throw const BleUnavailableException(BleUnavailableReason.unsupported);
    }
    if (!await _ensurePermissions()) {
      throw const BleUnavailableException(
        BleUnavailableReason.permissionDenied,
      );
    }
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      throw const BleUnavailableException(BleUnavailableReason.bluetoothOff);
    }
  }

  /// Requests the permissions a scan needs.
  ///
  /// Android 12 (API 31) split Bluetooth permissions out into `BLUETOOTH_SCAN`
  /// and `BLUETOOTH_CONNECT`; before that, a scan required location access
  /// because BLE beacons can be used to infer position. Requesting all three
  /// and accepting any granted combination covers both eras without
  /// branching on the OS version.
  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final scanGranted =
        (statuses[Permission.bluetoothScan]?.isGranted ?? false) ||
        (statuses[Permission.locationWhenInUse]?.isGranted ?? false);
    return scanGranted;
  }

  static BleAdvertisement _toAdvertisement(ScanResult result) {
    final advertisementData = result.advertisementData;

    return BleAdvertisement(
      deviceId: result.device.remoteId.str,
      name: advertisementData.advName,
      manufacturerData: advertisementData.manufacturerData,
      serviceData: {
        for (final entry in advertisementData.serviceData.entries)
          // flutter_blue_plus keys service data by full 128-bit Guid; the
          // sensors identify themselves by the 16-bit short form, which sits
          // in the third and fourth bytes of the standard Bluetooth base
          // UUID (0000xxxx-0000-1000-8000-00805f9b34fb).
          _shortUuid(entry.key): entry.value,
      },
    );
  }

  static int _shortUuid(Guid guid) {
    final hex = guid.str.replaceAll('-', '');
    if (hex.length < 8) return 0;
    return int.tryParse(hex.substring(4, 8), radix: 16) ?? 0;
  }
}
