import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:intl/intl.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/temperature_presentation.dart';

/// Indoor-source label shown on the Android home and lock-screen widgets.
///
/// Matches the dashboard chip so the widget never calls battery temperature
/// "Room Temperature" or "Phone Sensor".
String homeWidgetSourceLabel(RoomTemperatureSource source) {
  return switch (source) {
    RoomTemperatureSource.ambientSensor => 'Phone Sensor',
    RoomTemperatureSource.bluetoothSensor => 'Bluetooth Sensor',
    RoomTemperatureSource.batteryTemperature => 'Battery Temperature',
    RoomTemperatureSource.manual => 'Manual',
    RoomTemperatureSource.estimated => 'Estimated',
  };
}

/// Outdoor condition shown on the widget header.
String homeWidgetConditionLabel(WeatherCondition condition) {
  return switch (condition) {
    WeatherCondition.clear => 'Clear',
    WeatherCondition.partlyCloudy => 'Partly cloudy',
    WeatherCondition.cloudy => 'Cloudy',
    WeatherCondition.fog => 'Haze',
    WeatherCondition.drizzle => 'Drizzle',
    WeatherCondition.rain => 'Rain',
    WeatherCondition.snow => 'Snow',
    WeatherCondition.thunderstorm => 'Storm',
  };
}

/// Header date, e.g. `Wednesday, August 26`.
String homeWidgetDateLabel(DateTime value) {
  return DateFormat('EEEE, MMMM d', 'en').format(value);
}

/// Up to four forecast columns for the home widget strip.
List<HomeWidgetForecastDay> homeWidgetForecast({
  required OutsideWeather? weather,
  required Units units,
  required DateTime now,
}) {
  final days = weather?.forecastDays ?? const <DailyForecast>[];
  return [
    for (var i = 0; i < 4; i++)
      if (i < days.length)
        HomeWidgetForecastDay(
          label: homeWidgetForecastDayLabel(days[i].date, now),
          iconKey: days[i].condition.name,
          range:
              '${units.fromCelsius(days[i].maxCelsius).round()}'
              '${units.symbol}/'
              '${units.fromCelsius(days[i].minCelsius).round()}'
              '${units.symbol}',
        )
      else
        HomeWidgetForecastDay.empty,
  ];
}

/// `Today`, `Tomorrow`, or `MM/dd` relative to [now].
String homeWidgetForecastDayLabel(DateTime date, DateTime now) {
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) {
    return 'Today';
  }
  if (diff == 1) {
    return 'Tomorrow';
  }
  final month = date.month.toString().padLeft(2, '0');
  final dateDay = date.day.toString().padLeft(2, '0');
  return '$month/$dateDay';
}

/// Feels-like / humidity / wind / UV tiles, using dashboard formatters.
({String feelsLike, String humidity, String wind, String uv})
homeWidgetStatLabels({
  required OutsideWeather? weather,
  required Units units,
}) {
  return (
    feelsLike: WeatherFormat.temperatureWithUnit(
      weather?.apparentTemperatureCelsius,
      units,
    ),
    humidity: WeatherFormat.humidity(weather?.relativeHumidityPercent),
    wind: WeatherFormat.windSpeed(weather?.windSpeedKph),
    uv: WeatherFormat.uvIndex(weather?.uvIndex),
  );
}
