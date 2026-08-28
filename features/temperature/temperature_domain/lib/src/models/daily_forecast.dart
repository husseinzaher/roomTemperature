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

  /// Restores a [DailyForecast] from [toJson] output.
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date'] as String),
      condition: WeatherCondition.values.firstWhere(
        (value) => value.name == json['condition'],
        orElse: () => WeatherCondition.clear,
      ),
      maxCelsius: (json['maxCelsius'] as num).toDouble(),
      minCelsius: (json['minCelsius'] as num).toDouble(),
    );
  }

  /// Calendar date for this forecast day.
  final DateTime date;

  /// Typical condition for the day.
  final WeatherCondition condition;

  /// Daily high in Celsius.
  final double maxCelsius;

  /// Daily low in Celsius.
  final double minCelsius;

  /// Serializes this forecast day for local cache.
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'condition': condition.name,
    'maxCelsius': maxCelsius,
    'minCelsius': minCelsius,
  };

  @override
  List<Object?> get props => [date, condition, maxCelsius, minCelsius];
}
