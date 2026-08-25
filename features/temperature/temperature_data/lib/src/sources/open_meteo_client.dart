import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when [OpenMeteoClient] fails to fetch or parse the current
/// outside temperature from the Open-Meteo API.
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
/// temperature for a coordinate.
/// {@endtemplate}
class OpenMeteoClient {
  /// {@macro open_meteo_client}
  OpenMeteoClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetches the real current outside temperature in Celsius at
  /// ([latitude], [longitude]).
  ///
  /// Throws a [WeatherFetchException] if the request fails or the response
  /// body cannot be parsed.
  Future<double> fetchCurrentTemperatureCelsius({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m',
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
      final temperature = current['temperature_2m'];
      if (temperature is num) {
        return temperature.toDouble();
      }
      throw const FormatException('temperature_2m is missing or not a number');
    } catch (error) {
      throw WeatherFetchException(
        'Failed to parse Open-Meteo response: $error',
      );
    }
  }
}
