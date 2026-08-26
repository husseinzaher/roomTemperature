/// The broad weather condition at a location, mapped down from Open-Meteo's
/// numeric WMO weather codes.
///
/// Deliberately coarse: the UI picks a background image and a condition icon
/// per case, so a handful of buckets is more useful than ~30 exact codes.
enum WeatherCondition {
  /// Clear sky.
  clear,

  /// Mainly clear, or partly cloudy.
  partlyCloudy,

  /// Overcast.
  cloudy,

  /// Fog or depositing rime fog.
  fog,

  /// Drizzle, or light rain.
  drizzle,

  /// Rain, including rain showers.
  rain,

  /// Snow, snow grains, or snow showers.
  snow,

  /// Thunderstorm, with or without hail.
  thunderstorm;

  /// Maps a WMO weather interpretation code (as returned by Open-Meteo's
  /// `weather_code` field) to a [WeatherCondition].
  ///
  /// See https://open-meteo.com/en/docs for the full code table. Unknown
  /// codes fall back to [WeatherCondition.clear].
  static WeatherCondition fromWmoCode(int code) {
    return switch (code) {
      0 => WeatherCondition.clear,
      1 || 2 => WeatherCondition.partlyCloudy,
      3 => WeatherCondition.cloudy,
      45 || 48 => WeatherCondition.fog,
      51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
      61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => WeatherCondition.rain,
      71 || 73 || 75 || 77 || 85 || 86 => WeatherCondition.snow,
      95 || 96 || 99 => WeatherCondition.thunderstorm,
      _ => WeatherCondition.clear,
    };
  }
}
