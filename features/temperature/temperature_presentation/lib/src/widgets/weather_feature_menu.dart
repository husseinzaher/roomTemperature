import 'package:flutter/material.dart';
import 'package:temperature_presentation/src/widgets/weather_icon.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template weather_feature_menu}
/// The stack of onward-navigation rows below the weather sections:
/// five-day forecast, air quality, and radar.
///
/// The destination screens don't exist yet, so each row's callback is
/// optional — an unset callback leaves the row inert but still rendered, and
/// wiring a real screen later is a one-line change at the call site.
/// {@endtemplate}
class WeatherFeatureMenu extends StatelessWidget {
  /// {@macro weather_feature_menu}
  const WeatherFeatureMenu({
    required this.forecastLabel,
    required this.airQualityLabel,
    required this.radarLabel,
    super.key,
    this.onOpenForecast,
    this.onOpenAirQuality,
    this.onOpenRadar,
  });

  /// Localized title for the forecast row.
  final String forecastLabel;

  /// Localized title for the air-quality row.
  final String airQualityLabel;

  /// Localized title for the radar row.
  final String radarLabel;

  /// Called when the forecast row is tapped.
  final VoidCallback? onOpenForecast;

  /// Called when the air-quality row is tapped.
  final VoidCallback? onOpenAirQuality;

  /// Called when the radar row is tapped.
  final VoidCallback? onOpenRadar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassFeatureRow(
          icon: const WeatherIcon(WeatherIcons.forecast, size: 28),
          title: forecastLabel,
          onTap: onOpenForecast,
        ),
        const SizedBox(height: 12),
        GlassFeatureRow(
          icon: const WeatherIcon(WeatherIcons.airQuality, size: 28),
          title: airQualityLabel,
          onTap: onOpenAirQuality,
        ),
        const SizedBox(height: 12),
        GlassFeatureRow(
          icon: const WeatherIcon(WeatherIcons.radar, size: 28),
          title: radarLabel,
          onTap: onOpenRadar,
        ),
      ],
    );
  }
}
