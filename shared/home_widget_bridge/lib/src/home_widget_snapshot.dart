import 'package:home_widget_bridge/src/home_widget_forecast_day.dart';

/// {@template home_widget_snapshot}
/// Formatted reading the Android home and lock-screen widgets render.
///
/// Conversion into the user's unit happens before construction so this
/// package stays independent of the settings domain.
/// {@endtemplate}
class HomeWidgetSnapshot {
  /// {@macro home_widget_snapshot}
  const HomeWidgetSnapshot({
    required this.roomTemperature,
    required this.outsideTemperature,
    required this.unitSymbol,
    required this.sourceLabel,
    required this.thresholdBreached,
    required this.updatedAtLabel,
    this.locationLabel,
    this.dateLabel,
    this.conditionLabel,
    this.conditionIcon,
    this.feelsLikeLabel,
    this.humidityLabel,
    this.windLabel,
    this.uvLabel,
    this.forecast = const [],
  });

  /// Builds a snapshot from Celsius values, converting with
  /// [convertFromCelsius].
  factory HomeWidgetSnapshot.fromCelsius({
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
    required double Function(double celsius) convertFromCelsius,
    required String unitSymbol,
    required String sourceLabel,
    required bool thresholdBreached,
    required DateTime updatedAt,
    String? locationLabel,
    String? dateLabel,
    String? conditionLabel,
    String? conditionIcon,
    String? feelsLikeLabel,
    String? humidityLabel,
    String? windLabel,
    String? uvLabel,
    List<HomeWidgetForecastDay> forecast = const [],
  }) {
    return HomeWidgetSnapshot(
      roomTemperature: convertFromCelsius(
        roomTemperatureCelsius,
      ).toStringAsFixed(1),
      outsideTemperature: convertFromCelsius(
        outsideTemperatureCelsius,
      ).toStringAsFixed(1),
      unitSymbol: unitSymbol,
      sourceLabel: sourceLabel,
      thresholdBreached: thresholdBreached,
      updatedAtLabel: formatClock(updatedAt),
      locationLabel: locationLabel,
      dateLabel: dateLabel,
      conditionLabel: conditionLabel,
      conditionIcon: conditionIcon,
      feelsLikeLabel: feelsLikeLabel,
      humidityLabel: humidityLabel,
      windLabel: windLabel,
      uvLabel: uvLabel,
      forecast: forecast,
    );
  }

  /// Indoor temperature already converted and rounded, e.g. `24.5`.
  final String roomTemperature;

  /// Outdoor temperature already converted and rounded, e.g. `21.0`.
  final String outsideTemperature;

  /// Display unit, e.g. `°C`.
  final String unitSymbol;

  /// Provenance shown on the widget, e.g. `Battery Temperature`.
  final String sourceLabel;

  /// Reverse-geocoded locality, e.g. `Sandub`. Null hides the location row.
  final String? locationLabel;

  /// Full date for the header, e.g. `Wednesday, August 26`.
  final String? dateLabel;

  /// Outdoor condition, e.g. `Haze`.
  final String? conditionLabel;

  /// Weather condition name used to pick a drawable.
  final String? conditionIcon;

  /// Feels-like temperature with unit, e.g. `34.0 °C`.
  final String? feelsLikeLabel;

  /// Humidity, e.g. `36 %`.
  final String? humidityLabel;

  /// Wind speed, e.g. `12 km/h`.
  final String? windLabel;

  /// UV index, e.g. `8`.
  final String? uvLabel;

  /// Up to four forecast columns.
  ///
  /// Missing days are [HomeWidgetForecastDay.empty].
  final List<HomeWidgetForecastDay> forecast;

  /// Whether the indoor value is outside the user's alert range.
  final bool thresholdBreached;

  /// Clock time the reading was taken, `HH:mm`.
  final String updatedAtLabel;

  /// Formats [value] as a 24-hour `HH:mm` clock time.
  static String formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
