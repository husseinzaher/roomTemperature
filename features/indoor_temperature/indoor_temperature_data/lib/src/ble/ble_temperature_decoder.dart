import 'package:indoor_temperature_data/src/ble/atc_mi_decoder.dart';
import 'package:indoor_temperature_data/src/ble/govee_decoder.dart';
import 'package:indoor_temperature_domain/indoor_temperature_domain.dart';

/// Decodes a BLE advertisement from any temperature sensor family the app
/// understands.
///
/// Adding a new sensor family means adding one decoder and listing it here —
/// nothing above this class changes.
abstract final class BleTemperatureDecoder {
  /// Every supported family's decoder, tried in order.
  static const List<BleTemperatureSample? Function(BleAdvertisement)>
  _decoders = [AtcMiDecoder.decode, GoveeDecoder.decode];

  /// Decodes [advertisement], or returns null when no supported sensor
  /// family recognises it.
  static BleTemperatureSample? decode(BleAdvertisement advertisement) {
    for (final decode in _decoders) {
      final sample = decode(advertisement);
      if (sample != null) return sample;
    }
    return null;
  }

  /// Whether [advertisement] comes from a sensor the app can read, used to
  /// filter scan results down to usable devices.
  static bool isSupportedSensor(BleAdvertisement advertisement) =>
      decode(advertisement) != null;
}
