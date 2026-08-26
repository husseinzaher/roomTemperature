import 'package:flutter/material.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/src/format/weather_format.dart';
import 'package:temperature_presentation/src/widgets/weather_icon.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template weather_stats_grid}
/// The 3 x 2 grid of outside-weather detail tiles: feels like, humidity,
/// wind, pressure, sunset, and UV index.
///
/// Tiles are always all six, in a fixed order — a missing measurement shows
/// a placeholder rather than collapsing the grid, so the layout never
/// reflows between refreshes.
/// {@endtemplate}
class WeatherStatsGrid extends StatelessWidget {
  /// {@macro weather_stats_grid}
  const WeatherStatsGrid({
    required this.weather,
    required this.units,
    required this.labels,
    super.key,
  });

  /// The outside conditions to display. When null every tile shows a
  /// placeholder.
  final OutsideWeather? weather;

  /// The unit the temperatures should be shown in.
  final Units units;

  /// Localized tile labels.
  final WeatherStatsLabels labels;

  @override
  Widget build(BuildContext context) {
    final stats = <({IconData icon, String label, String value})>[
      (
        icon: WeatherIcons.feelsLike,
        label: labels.feelsLike,
        value: WeatherFormat.temperatureWithUnit(
          weather?.apparentTemperatureCelsius,
          units,
        ),
      ),
      (
        icon: WeatherIcons.humidity,
        label: labels.humidity,
        value: WeatherFormat.humidity(weather?.relativeHumidityPercent),
      ),
      (
        icon: WeatherIcons.wind,
        label: labels.windSpeed,
        value: WeatherFormat.windSpeed(weather?.windSpeedKph),
      ),
      (
        icon: WeatherIcons.pressure,
        label: labels.pressure,
        value: WeatherFormat.pressure(weather?.surfacePressureHpa),
      ),
      (
        icon: WeatherIcons.sunset,
        label: labels.sunset,
        value: WeatherFormat.sunsetTime(weather?.sunset),
      ),
      (
        icon: WeatherIcons.uvIndex,
        label: labels.uvIndex,
        value: WeatherFormat.uvIndex(weather?.uvIndex),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        const columns = 3;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        // Slightly taller than wide, matching the reference proportions,
        // but derived from the measured width so it adapts to any screen.
        final tileHeight = (tileWidth * 1.22).clamp(112.0, 150.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: GlassStatTile(
                  icon: WeatherIcon(stat.icon, size: 32),
                  label: stat.label,
                  value: stat.value,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Localized labels for the six [WeatherStatsGrid] tiles.
class WeatherStatsLabels {
  /// Creates a [WeatherStatsLabels].
  const WeatherStatsLabels({
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.sunset,
    required this.uvIndex,
  });

  /// Label for the apparent-temperature tile.
  final String feelsLike;

  /// Label for the humidity tile.
  final String humidity;

  /// Label for the wind-speed tile.
  final String windSpeed;

  /// Label for the pressure tile.
  final String pressure;

  /// Label for the sunset tile.
  final String sunset;

  /// Label for the UV-index tile.
  final String uvIndex;
}
