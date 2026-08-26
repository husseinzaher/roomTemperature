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
  static const String _reverseGeocodeUrl =
      'https://nominatim.openstreetmap.org/reverse';

  /// Nominatim requires an identifying User-Agent; the default Dart client
  /// header is rejected.
  static const Map<String, String> _nominatimHeaders = {
    'User-Agent': 'RoomTemperature/1.0 (com.comma.room_temperature)',
    'Accept-Language': 'en',
  };

  static const String _currentFields =
      'temperature_2m,apparent_temperature,relative_humidity_2m,'
      'wind_speed_10m,surface_pressure,weather_code,is_day';

  static const String _dailyFields =
      'sunset,uv_index_max,temperature_2m_max,temperature_2m_min,weather_code';

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
      '&forecast_days=4',
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

    final OutsideWeather parsed;
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

      parsed = OutsideWeather(
        temperatureCelsius: temperature,
        condition: WeatherCondition.fromWmoCode(weatherCode),
        isDay: isDay == 1,
        apparentTemperatureCelsius: _asDouble(current['apparent_temperature']),
        relativeHumidityPercent: _asDouble(current['relative_humidity_2m']),
        windSpeedKph: _asDouble(current['wind_speed_10m']),
        surfacePressureHpa: _asDouble(current['surface_pressure']),
        uvIndex: _asDouble(_firstOfDaily(daily, 'uv_index_max')),
        sunset: _asDateTime(_firstOfDaily(daily, 'sunset')),
        forecastDays: _parseDailyForecast(daily),
      );
    } catch (error) {
      throw WeatherFetchException(
        'Failed to parse Open-Meteo response: $error',
      );
    }

    return OutsideWeather(
      temperatureCelsius: parsed.temperatureCelsius,
      condition: parsed.condition,
      isDay: parsed.isDay,
      apparentTemperatureCelsius: parsed.apparentTemperatureCelsius,
      relativeHumidityPercent: parsed.relativeHumidityPercent,
      windSpeedKph: parsed.windSpeedKph,
      surfacePressureHpa: parsed.surfacePressureHpa,
      uvIndex: parsed.uvIndex,
      sunset: parsed.sunset,
      placeName: await _lookupPlaceName(latitude, longitude),
      forecastDays: parsed.forecastDays,
    );
  }

  /// Best-effort reverse-geocode of ([latitude], [longitude]).
  ///
  /// Open-Meteo has no reverse-geocoding API, so this uses Nominatim.
  /// A missing or unreadable place name must never fail the weather fetch:
  /// the dashboard simply omits the location row.
  Future<String?> _lookupPlaceName(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        '$_reverseGeocodeUrl?lat=$latitude&lon=$longitude'
        '&format=jsonv2&zoom=10&addressdetails=1',
      );
      final response = await _httpClient.get(
        uri,
        headers: _nominatimHeaders,
      );
      if (response.statusCode != 200) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return placeNameFromNominatim(decoded);
    } on Object {
      return null;
    }
  }

  /// Picks a locality from a Nominatim reverse-geocoding payload.
  ///
  /// Prefers city/town/village over the longer `display_name` so the
  /// dashboard and widgets can show a short pin label like `Sandub`.
  static String? placeNameFromNominatim(Map<String, dynamic> decoded) {
    const localityKeys = [
      'city',
      'town',
      'village',
      'municipality',
      'suburb',
      'hamlet',
      'county',
      'state',
    ];
    final address = decoded['address'];
    if (address is Map) {
      for (final key in localityKeys) {
        final value = address[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    final name = decoded['name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }
    return null;
  }

  /// Returns [value] as a `Map` if it is one, and `null` otherwise.
  static Map<String, dynamic>? _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : null;

  /// Reads the first element of the `daily` array named [key].
  ///
  /// Daily fields come back as lists, one value per forecast day. Returns
  /// `null` if [daily] is absent, the field is missing, or the list is empty.
  static Object? _firstOfDaily(Map<String, dynamic>? daily, String key) {
    final values = daily?[key];
    if (values is List && values.isNotEmpty) {
      return values.first;
    }
    return null;
  }

  /// Parses up to four [DailyForecast] days from an Open-Meteo `daily` map.
  static List<DailyForecast> _parseDailyForecast(Map<String, dynamic>? daily) {
    if (daily == null) {
      return const [];
    }
    final times = daily['time'];
    final maxes = daily['temperature_2m_max'];
    final mins = daily['temperature_2m_min'];
    final codes = daily['weather_code'];
    if (times is! List || maxes is! List || mins is! List || codes is! List) {
      return const [];
    }
    var count = times.length;
    if (maxes.length < count) {
      count = maxes.length;
    }
    if (mins.length < count) {
      count = mins.length;
    }
    if (codes.length < count) {
      count = codes.length;
    }
    if (count > 4) {
      count = 4;
    }
    final days = <DailyForecast>[];
    for (var i = 0; i < count; i++) {
      final date = _asDateTime(times[i]);
      final max = _asDouble(maxes[i]);
      final min = _asDouble(mins[i]);
      final code = _asInt(codes[i]);
      if (date == null || max == null || min == null || code == null) {
        continue;
      }
      days.add(
        DailyForecast(
          date: date,
          condition: WeatherCondition.fromWmoCode(code),
          maxCelsius: max,
          minCelsius: min,
        ),
      );
    }
    return days;
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
