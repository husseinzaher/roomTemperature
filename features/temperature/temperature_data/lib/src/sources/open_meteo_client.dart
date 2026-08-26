import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:temperature_domain/temperature_domain.dart';

/// Thrown when [OpenMeteoClient] fails to fetch or parse the current
/// outside weather from the Open-Meteo API.
class WeatherFetchException implements Exception {
  /// Creates a [WeatherFetchException] with a human-readable [message].
  const WeatherFetchException(this.message);

  /// A human-readable description of what went wrong.
  final String message;

  @override
  String toString() => 'WeatherFetchException: $message';
}

/// {@template open_meteo_client}
/// A thin client around the free, keyless Open-Meteo weather API
/// (https://open-meteo.com) that fetches the real current outside
/// weather for a coordinate.
/// {@endtemplate}
class OpenMeteoClient {
  /// {@macro open_meteo_client}
  OpenMeteoClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static const String _currentFields =
      'temperature_2m,apparent_temperature,relative_humidity_2m,'
      'wind_speed_10m,surface_pressure,weather_code,is_day';

  static const String _dailyFields = 'sunset,uv_index_max';

  /// Fetches the current outside weather at ([latitude], [longitude]).
  ///
  /// [OutsideWeather.temperatureCelsius], [OutsideWeather.condition] and
  /// [OutsideWeather.isDay] are required: if any of them is missing from the
  /// response, or is not of the expected type, a [WeatherFetchException] is
  /// thrown. Every other field is best-effort — a missing, null or
  /// unparseable value simply becomes `null`, so a partial response still
  /// yields a usable [OutsideWeather].
  ///
  /// Throws a [WeatherFetchException] if the request fails, the status code
  /// is not 200, or the response body cannot be parsed.
  Future<OutsideWeather> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&current=$_currentFields'
      '&daily=$_dailyFields'
      '&timezone=auto'
      '&forecast_days=1',
    );

    final http.Response response;
    try {
      response = await _httpClient.get(uri);
    } catch (error) {
      throw WeatherFetchException('Failed to reach Open-Meteo: $error');
    }

    if (response.statusCode != 200) {
      throw WeatherFetchException(
        'Open-Meteo returned status ${response.statusCode}: ${response.body}',
      );
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final current = decoded['current'] as Map<String, dynamic>;
      final daily = _asMap(decoded['daily']);

      final temperature = _asDouble(current['temperature_2m']);
      if (temperature == null) {
        throw const FormatException(
          'temperature_2m is missing or not a number',
        );
      }

      final weatherCode = _asInt(current['weather_code']);
      if (weatherCode == null) {
        throw const FormatException('weather_code is missing or not a number');
      }

      final isDay = _asInt(current['is_day']);
      if (isDay == null) {
        throw const FormatException('is_day is missing or not a number');
      }

      return OutsideWeather(
        temperatureCelsius: temperature,
        condition: WeatherCondition.fromWmoCode(weatherCode),
        isDay: isDay == 1,
        apparentTemperatureCelsius: _asDouble(current['apparent_temperature']),
        relativeHumidityPercent: _asDouble(current['relative_humidity_2m']),
        windSpeedKph: _asDouble(current['wind_speed_10m']),
        surfacePressureHpa: _asDouble(current['surface_pressure']),
        uvIndex: _asDouble(_firstOfDaily(daily, 'uv_index_max')),
        sunset: _asDateTime(_firstOfDaily(daily, 'sunset')),
      );
    } catch (error) {
      throw WeatherFetchException(
        'Failed to parse Open-Meteo response: $error',
      );
    }
  }

  /// Returns [value] as a `Map` if it is one, and `null` otherwise.
  static Map<String, dynamic>? _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : null;

  /// Reads the first element of the `daily` array named [key].
  ///
  /// Because the request asks for `forecast_days=1`, every `daily` field comes
  /// back as a single-element list. Returns `null` if [daily] is absent, the
  /// field is missing, or the list is empty.
  static Object? _firstOfDaily(Map<String, dynamic>? daily, String key) {
    final values = daily?[key];
    if (values is List && values.isNotEmpty) {
      return values.first;
    }
    return null;
  }

  /// Parses [value] as a `double`, tolerating both `int` and `double` JSON
  /// numbers. Returns `null` for anything else.
  static double? _asDouble(Object? value) =>
      value is num ? value.toDouble() : null;

  /// Parses [value] as an `int`, tolerating both `int` and `double` JSON
  /// numbers. Returns `null` for anything else.
  static int? _asInt(Object? value) => value is num ? value.toInt() : null;

  /// Parses [value] as an ISO-8601 local datetime string, returning `null` if
  /// it is not a string or cannot be parsed.
  static DateTime? _asDateTime(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
