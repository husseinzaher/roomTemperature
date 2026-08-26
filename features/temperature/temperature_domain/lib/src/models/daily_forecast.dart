import 'package:equatable/equatable.dart';
import 'package:temperature_domain/src/models/weather_condition.dart';

/// {@template daily_forecast}
/// One day of the outdoor forecast: high, low, and condition.
/// {@endtemplate}
class DailyForecast extends Equatable {
  /// {@macro daily_forecast}
  const DailyForecast({
    required this.date,
    required this.condition,
    required this.maxCelsius,
    required this.minCelsius,
  });

  /// Calendar date for this forecast day.
  final DateTime date;

  /// Typical condition for the day.
  final WeatherCondition condition;

  /// Daily high in Celsius.
  final double maxCelsius;

  /// Daily low in Celsius.
  final double minCelsius;

  @override
  List<Object?> get props => [date, condition, maxCelsius, minCelsius];
}
