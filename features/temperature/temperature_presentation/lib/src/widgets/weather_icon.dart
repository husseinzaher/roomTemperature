import 'package:flutter/material.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// The app's one weather-icon source.
///
/// Every icon comes from a single outlined family at a consistent stroke
/// weight and color, so the set reads as one system rather than a pile of
/// mixed glyphs. Callers pick a size; color defaults to the on-glass tint.
abstract final class WeatherIcons {
  /// The icon representing a [WeatherCondition], varying by day or night.
  static IconData forCondition(
    WeatherCondition condition, {
    bool isDay = true,
  }) {
    return switch (condition) {
      WeatherCondition.clear =>
        isDay ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
      WeatherCondition.partlyCloudy =>
        isDay ? Icons.wb_cloudy_outlined : Icons.nights_stay_outlined,
      WeatherCondition.cloudy => Icons.cloud_outlined,
      WeatherCondition.fog => Icons.foggy,
      WeatherCondition.drizzle => Icons.grain_outlined,
      WeatherCondition.rain => Icons.water_drop_outlined,
      WeatherCondition.snow => Icons.ac_unit_outlined,
      WeatherCondition.thunderstorm => Icons.thunderstorm_outlined,
    };
  }

  /// Indoor thermometer icon.
  static const IconData indoor = Icons.device_thermostat_outlined;

  /// "Feels like" icon.
  static const IconData feelsLike = Icons.thermostat_auto_outlined;

  /// Humidity icon.
  static const IconData humidity = Icons.water_drop_outlined;

  /// Wind speed icon.
  static const IconData wind = Icons.air_outlined;

  /// Pressure icon.
  static const IconData pressure = Icons.speed_outlined;

  /// Sunset icon.
  static const IconData sunset = Icons.wb_twilight_outlined;

  /// UV index icon.
  static const IconData uvIndex = Icons.wb_sunny_outlined;

  /// Multi-day forecast icon.
  static const IconData forecast = Icons.calendar_month_outlined;

  /// Air-quality icon.
  static const IconData airQuality = Icons.blur_on_outlined;

  /// Weather-radar icon.
  static const IconData radar = Icons.radar_outlined;
}

/// {@template weather_icon}
/// A line icon drawn in the shared on-glass style.
/// {@endtemplate}
class WeatherIcon extends StatelessWidget {
  /// {@macro weather_icon}
  const WeatherIcon(this.icon, {super.key, this.size = 30, this.color});

  /// The glyph to draw. Use a [WeatherIcons] member so the set stays
  /// consistent.
  final IconData icon;

  /// The icon's size.
  final double size;

  /// Overrides the default on-glass color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? GlassTokens.onGlass,
    );
  }
}
