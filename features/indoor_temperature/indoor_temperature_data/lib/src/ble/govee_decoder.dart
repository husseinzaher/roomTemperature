import 'package:indoor_temperature_domain/indoor_temperature_domain.dart';

/// Decodes temperature broadcasts from Govee hygrometers (H5072, H5075,
/// H5101, H5102 and relatives).
///
/// These models pack temperature and humidity together into a single 24-bit
/// integer inside their manufacturer-specific advertisement data:
///
/// * `value = (b0 << 16) | (b1 << 8) | b2`
/// * bit 23 is a sign flag for sub-zero temperatures
/// * `temperatureC = ((value & 0x7FFFFF) / 1000).floor() / 10`
/// * `humidity% = (value & 0x7FFFFF) % 1000 / 10`
///
/// Reference: the `govee-ble` decoder used by Home Assistant
/// (https://github.com/Bluetooth-Devices/govee-ble).
abstract final class GoveeDecoder {
  /// The 16-bit company identifier Govee advertises under.
  ///
  /// Bluetooth company ids are little-endian on the wire, which is why this
  /// is widely written as both `0x88EC` and `0xEC88`; `flutter_blue_plus`
  /// hands back the already-byte-swapped integer, so `0xEC88` is what a key
  /// in `manufacturerData` actually compares equal to.
  static const int companyId = 0xEC88;

  /// A plausible indoor/outdoor air-temperature window. Used to reject a
  /// misaligned decode rather than surfacing a nonsense reading.
  static const double _minPlausibleC = -40;
  static const double _maxPlausibleC = 80;

  /// Decodes [advertisement], or returns null if it isn't a recognisable
  /// Govee temperature broadcast.
  static BleTemperatureSample? decode(BleAdvertisement advertisement) {
    final bytes = advertisement.manufacturerData[companyId];
    if (bytes == null) return null;

    // The packed triple always starts at offset 1, after a leading status
    // byte — matching the reference `govee-ble` parser, which reads
    // `data[1:5]`.
    //
    // Deliberately no "try other offsets" fallback: the same five bytes can
    // decode to a plausible-looking temperature at more than one offset, so
    // guessing would risk silently displaying a confidently wrong reading.
    // Failing to decode is the safer outcome — the source then reports
    // itself unavailable and Automatic falls through to the next one.
    return _decodeAt(advertisement.deviceId, bytes, 1);
  }

  static BleTemperatureSample? _decodeAt(
    String deviceId,
    List<int> bytes,
    int offset,
  ) {
    if (bytes.length < offset + 3) return null;

    final packed =
        (bytes[offset] << 16) | (bytes[offset + 1] << 8) | bytes[offset + 2];
    final magnitude = packed & 0x7FFFFF;

    // Integer-divide by 1000 before scaling: the low three digits carry
    // humidity, so truncation here is deliberate, not a rounding bug.
    final celsius = (magnitude ~/ 1000) / 10.0;
    final signedCelsius = (packed & 0x800000) != 0 ? -celsius : celsius;

    if (signedCelsius < _minPlausibleC || signedCelsius > _maxPlausibleC) {
      return null;
    }

    final humidity = (magnitude % 1000) / 10.0;
    if (humidity > 100) return null;

    // The byte after the packed triple is battery percent, with the top
    // bit used as a flag on some models.
    final batteryIndex = offset + 3;
    final battery = batteryIndex < bytes.length
        ? bytes[batteryIndex] & 0x7F
        : null;

    return BleTemperatureSample(
      deviceId: deviceId,
      celsius: signedCelsius,
      humidityPercent: humidity,
      batteryPercent: battery != null && battery <= 100 ? battery : null,
    );
  }
}
