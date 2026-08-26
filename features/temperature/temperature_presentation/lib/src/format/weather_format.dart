import 'package:settings_domain/settings_domain.dart';

/// Formatters for every number the weather UI displays.
///
/// The UI never receives a raw `double` — all of it comes through here, so a
/// full-precision float like `1.000000150474402` can't reach the screen.
abstract final class WeatherFormat {
  /// Placeholder shown when a measurement is unavailable.
  static const String unavailable = '—';

  /// A temperature converted into [units] and rendered to one decimal, with
  /// no unit symbol (the symbol is displayed separately, as a superscript).
  static String temperatureValue(double celsius, Units units) {
    return units.fromCelsius(celsius).toStringAsFixed(1);
  }

  /// A temperature converted into [units], rendered to one decimal with its
  /// unit symbol appended — for the compact stat tiles.
  static String temperatureWithUnit(double? celsius, Units units) {
    if (celsius == null) return unavailable;
    return '${units.fromCelsius(celsius).toStringAsFixed(1)} ${units.symbol}';
  }

  /// A relative humidity percentage, rounded to a whole number.
  static String humidity(double? percent) {
    if (percent == null) return unavailable;
    return '${percent.round()} %';
  }

  /// A wind speed in km/h, rounded to a whole number.
  static String windSpeed(double? kph) {
    if (kph == null) return unavailable;
    return '${kph.round()} km/h';
  }

  /// A surface pressure in hPa, rounded to a whole number.
  static String pressure(double? hpa) {
    if (hpa == null) return unavailable;
    return '${hpa.round()} hPa';
  }

  /// A UV index, rounded to a whole number.
  static String uvIndex(double? index) {
    if (index == null) return unavailable;
    return '${index.round()}';
  }

  /// A sunset time as 12-hour `hh:mm AM/PM`.
  ///
  /// Reads only the wall-clock fields of [sunset] and never compares it
  /// against `DateTime.now()`. Open-Meteo returns sunset as a zone-less
  /// local timestamp for the *queried location*, which Dart parses into the
  /// device's zone — so the fields are correct to display but the instant
  /// is not, and any arithmetic against the current time would be wrong.
  static String sunsetTime(DateTime? sunset) {
    if (sunset == null) return unavailable;
    final hour24 = sunset.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = switch (hour24 % 12) {
      0 => 12,
      final h => h,
    };
    final minute = sunset.minute.toString().padLeft(2, '0');
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  /// A "last updated at" clock time as 24-hour `HH:mm`.
  static String updatedAt(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
