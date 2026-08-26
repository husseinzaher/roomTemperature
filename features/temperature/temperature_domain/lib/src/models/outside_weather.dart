import 'package:equatable/equatable.dart';
import 'package:temperature_domain/src/models/weather_condition.dart';

/// {@template outside_weather}
/// The full current outside weather at a location — everything the dashboard
/// displays for the "outside" half of the app.
///
/// Every field is optional except [temperatureCelsius] and [condition],
/// because Open-Meteo can omit individual measurements depending on the
/// location and model coverage. The UI shows a placeholder for a missing
/// value rather than hiding the card, so the grid layout stays stable.
/// {@endtemplate}
class OutsideWeather extends Equatable {
  /// {@macro outside_weather}
  const OutsideWeather({
    required this.temperatureCelsius,
    required this.condition,
    required this.isDay,
    this.apparentTemperatureCelsius,
    this.relativeHumidityPercent,
    this.windSpeedKph,
    this.surfacePressureHpa,
    this.uvIndex,
    this.sunset,
  });

  /// The real air temperature in Celsius.
  final double temperatureCelsius;

  /// The broad weather condition, used to pick a background and icon.
  final WeatherCondition condition;

  /// Whether it is currently daytime at the location. Drives the day/night
  /// variant of the background and condition icon.
  final bool isDay;

  /// The "feels like" temperature in Celsius, accounting for wind and
  /// humidity.
  final double? apparentTemperatureCelsius;

  /// Relative humidity as a percentage (0-100).
  final double? relativeHumidityPercent;

  /// Wind speed in kilometres per hour.
  final double? windSpeedKph;

  /// Surface pressure in hectopascals.
  final double? surfacePressureHpa;

  /// The UV index (typically 0-11+).
  final double? uvIndex;

  /// Today's sunset time, in the location's local time.
  final DateTime? sunset;

  @override
  List<Object?> get props => [
    temperatureCelsius,
    condition,
    isDay,
    apparentTemperatureCelsius,
    relativeHumidityPercent,
    windSpeedKph,
    surfacePressureHpa,
    uvIndex,
    sunset,
  ];
}
