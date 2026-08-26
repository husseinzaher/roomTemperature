import 'dart:typed_data';

import 'package:indoor_temperature_domain/indoor_temperature_domain.dart';

/// Decodes temperature broadcasts from Xiaomi LYWSD03MMC / MJWSD05MMC
/// thermometers running the ATC or pvvx custom firmware, which advertise
/// under the Environmental Sensing service UUID `0x181A`.
///
/// Two payload layouts exist. Both begin with the sensor's six-byte MAC, so
/// they are told apart by length:
///
/// **atc1441 — 13 bytes**
/// | offset | field                        |
/// | ------ | ---------------------------- |
/// | 0-5    | MAC                          |
/// | 6-7    | temperature, int16, x0.1 C   |
/// | 8      | humidity, uint8, %           |
/// | 9      | battery, uint8, %            |
/// | 10-11  | battery, uint16, mV          |
/// | 12     | frame counter                |
///
/// **pvvx custom — 15 bytes**
/// | offset | field                             |
/// | ------ | --------------------------------- |
/// | 0-5    | MAC                               |
/// | 6-7    | temperature, int16 LE, x0.01 C    |
/// | 8-9    | humidity, uint16 LE, x0.01 %      |
/// | 10-11  | battery, uint16 LE, mV            |
/// | 12     | battery, uint8, %                 |
/// | 13     | frame counter                     |
/// | 14     | flags                             |
///
/// Reference: https://github.com/pvvx/ATC_MiThermometer
///
/// The atc1441 layout is documented as little-endian by pvvx but ships
/// big-endian in some builds, so [decode] tries little-endian first and
/// falls back to big-endian when the result is implausible.
abstract final class AtcMiDecoder {
  /// The Environmental Sensing service UUID these firmwares advertise on.
  static const int serviceUuid = 0x181A;

  static const int _atc1441Length = 13;
  static const int _pvvxLength = 15;

  static const double _minPlausibleC = -40;
  static const double _maxPlausibleC = 80;

  /// Decodes [advertisement], or returns null if it isn't a recognisable
  /// ATC/pvvx temperature broadcast.
  static BleTemperatureSample? decode(BleAdvertisement advertisement) {
    final bytes = advertisement.serviceData[serviceUuid];
    if (bytes == null) return null;

    return switch (bytes.length) {
      _pvvxLength => _decodePvvx(advertisement.deviceId, bytes),
      _atc1441Length => _decodeAtc1441(advertisement.deviceId, bytes),
      _ => null,
    };
  }

  static BleTemperatureSample? _decodePvvx(String deviceId, List<int> bytes) {
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final celsius = data.getInt16(6, Endian.little) / 100.0;
    if (!_isPlausible(celsius)) return null;

    final humidity = data.getUint16(8, Endian.little) / 100.0;
    final battery = bytes[12];

    return BleTemperatureSample(
      deviceId: deviceId,
      celsius: celsius,
      humidityPercent: humidity <= 100 ? humidity : null,
      batteryPercent: battery <= 100 ? battery : null,
    );
  }

  static BleTemperatureSample? _decodeAtc1441(
    String deviceId,
    List<int> bytes,
  ) {
    final data = ByteData.sublistView(Uint8List.fromList(bytes));

    var celsius = data.getInt16(6, Endian.little) / 10.0;
    if (!_isPlausible(celsius)) {
      celsius = data.getInt16(6, Endian.big) / 10.0;
      if (!_isPlausible(celsius)) return null;
    }

    final humidity = bytes[8];
    final battery = bytes[9];

    return BleTemperatureSample(
      deviceId: deviceId,
      celsius: celsius,
      humidityPercent: humidity <= 100 ? humidity.toDouble() : null,
      batteryPercent: battery <= 100 ? battery : null,
    );
  }

  static bool _isPlausible(double celsius) =>
      celsius >= _minPlausibleC && celsius <= _maxPlausibleC;
}
