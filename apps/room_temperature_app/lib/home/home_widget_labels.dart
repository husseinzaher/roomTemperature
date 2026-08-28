import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:room_temperature_app/places/place_models.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/temperature_presentation.dart';

const _weekdaysShort = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const _weekdaysLong = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

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
  return '${_weekdaysLong[value.weekday - 1]}, '
      '${_months[value.month - 1]} ${value.day}';
}

/// Compact clock-subheader date, e.g. `Fri, August 28`.
String homeWidgetShortDateLabel(DateTime value) {
  final short = _weekdaysShort[value.weekday - 1];
  final titled = '${short[0]}${short.substring(1).toLowerCase()}';
  return '$titled, ${_months[value.month - 1]} ${value.day}';
}

/// Up to five forecast columns for the home widget strip.
List<HomeWidgetForecastDay> homeWidgetForecast({
  required OutsideWeather? weather,
  required Units units,
  required DateTime now,
}) {
  final days = weather?.forecastDays ?? const <DailyForecast>[];
  return [
    for (var i = 0; i < 5; i++)
      if (i < days.length)
        HomeWidgetForecastDay(
          label: homeWidgetForecastDayLabel(days[i].date, now),
          iconKey: days[i].condition.name,
          range:
              '${units.fromCelsius(days[i].maxCelsius).round()}'
              '${units.symbol}/'
              '${units.fromCelsius(days[i].minCelsius).round()}'
              '${units.symbol}',
          high:
              '${units.fromCelsius(days[i].maxCelsius).round()}'
              '${units.symbol}',
        )
      else
        HomeWidgetForecastDay.empty,
  ];
}

/// `Today` for the current calendar day, otherwise a weekday like `MON`.
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
  return _weekdaysShort[date.weekday - 1];
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

/// Formatted place rows for the dedicated places widget.
List<HomeWidgetPlaceRow> homeWidgetPlaces({
  required List<PlaceSummary> places,
  required Units units,
  required DateTime now,
}) {
  return [
    for (final place in places.take(5))
      HomeWidgetPlaceRow(
        name: place.name,
        temperature: place.averageIndoorCelsius == null
            ? '—'
            : units.fromCelsius(place.averageIndoorCelsius!).toStringAsFixed(1),
        subtitle: place.lastVisitAt == null
            ? ''
            : homeWidgetForecastDayLabel(place.lastVisitAt!, now),
      ),
  ];
}

/// Pushes [reading] (and optional [weather] / places) to every Android widget.
Future<void> syncHomeWidget({
  required HomeWidgetBridge bridge,
  required Reading reading,
  required UserSettings settings,
  OutsideWeather? weather,
  PlaceSummary? recentPlace,
  List<PlaceSummary> places = const [],
  DateTime? clockAt,
}) {
  final units = settings.units;
  final threshold = settings.threshold;
  final breached =
      threshold.enabled &&
      (reading.roomTemperatureCelsius < threshold.minCelsius ||
          reading.roomTemperatureCelsius > threshold.maxCelsius);
  final stats = homeWidgetStatLabels(weather: weather, units: units);
  final placeAverage = recentPlace?.averageIndoorCelsius;

  return bridge.updateReading(
    HomeWidgetSnapshot.fromCelsius(
      roomTemperatureCelsius: reading.roomTemperatureCelsius,
      outsideTemperatureCelsius: reading.outsideTemperatureCelsius,
      convertFromCelsius: units.fromCelsius,
      unitSymbol: units.symbol,
      sourceLabel: homeWidgetSourceLabel(reading.roomTemperatureSource),
      thresholdBreached: breached,
      updatedAt: reading.timestamp,
      clockAt: clockAt ?? DateTime.now(),
      locationLabel: weather?.placeName,
      dateLabel: homeWidgetDateLabel(reading.timestamp),
      shortDateLabel: homeWidgetShortDateLabel(reading.timestamp),
      conditionLabel: weather == null
          ? null
          : homeWidgetConditionLabel(weather.condition),
      conditionIcon: weather?.condition.name,
      feelsLikeLabel: stats.feelsLike,
      humidityLabel: stats.humidity,
      windLabel: stats.wind,
      uvLabel: stats.uv,
      placeName: recentPlace?.name,
      placeAverageLabel: placeAverage == null
          ? null
          : '${units.fromCelsius(placeAverage).toStringAsFixed(1)}'
                '${units.symbol}',
      forecast: homeWidgetForecast(
        weather: weather,
        units: units,
        now: reading.timestamp,
      ),
      places: homeWidgetPlaces(
        places: places,
        units: units,
        now: reading.timestamp,
      ),
    ),
  );
}
