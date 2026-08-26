import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

/// A complete Open-Meteo response body, as returned for the documented
/// `current` + `daily` field set.
String _fullBody({int weatherCode = 0, int isDay = 1}) => jsonEncode({
  'current': {
    'temperature_2m': 21.4,
    'apparent_temperature': 23.1,
    'relative_humidity_2m': 62,
    'wind_speed_10m': 12.6,
    'surface_pressure': 1004.2,
    'weather_code': weatherCode,
    'is_day': isDay,
  },
  'daily': {
    'sunset': ['2026-08-26T19:26'],
    'uv_index_max': [8.35],
  },
});

void main() {
  group('OpenMeteoClient', () {
    late http.Client httpClient;
    late OpenMeteoClient client;

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://api.open-meteo.com'));
      registerFallbackValue(<String, String>{});
    });

    setUp(() {
      httpClient = MockHttpClient();
      client = OpenMeteoClient(httpClient: httpClient);
    });

    void stubHttp({
      required String forecastBody,
      int forecastStatus = 200,
      String nominatimBody = '{}',
      int nominatimStatus = 200,
      Exception? forecastThrow,
      Exception? nominatimThrow,
    }) {
      Future<http.Response> respond(Invocation invocation) async {
        final uri = invocation.positionalArguments.first as Uri;
        if (uri.host.contains('nominatim')) {
          if (nominatimThrow != null) {
            throw nominatimThrow;
          }
          return http.Response(nominatimBody, nominatimStatus);
        }
        if (forecastThrow != null) {
          throw forecastThrow;
        }
        return http.Response(forecastBody, forecastStatus);
      }

      when(() => httpClient.get(any())).thenAnswer(respond);
      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(respond);
    }

    void stubResponse(String body, [int statusCode = 200]) {
      stubHttp(forecastBody: body, forecastStatus: statusCode);
    }

    test('parses every field from a full successful response', () async {
      stubResponse(_fullBody());

      final result = await client.fetchCurrentWeather(
        latitude: 25.276987,
        longitude: 55.296249,
      );

      expect(result.temperatureCelsius, 21.4);
      expect(result.condition, WeatherCondition.clear);
      expect(result.isDay, isTrue);
      expect(result.apparentTemperatureCelsius, 23.1);
      expect(result.relativeHumidityPercent, 62.0);
      expect(result.windSpeedKph, 12.6);
      expect(result.surfacePressureHpa, 1004.2);
      expect(result.uvIndex, 8.35);
      expect(result.sunset, DateTime(2026, 8, 26, 19, 26));
      expect(result.placeName, isNull);
      expect(result.forecastDays, isEmpty);
    });

    test('requests the expected Open-Meteo URL', () async {
      stubResponse(_fullBody());

      await client.fetchCurrentWeather(latitude: 1, longitude: 2);

      final captured = verify(() => httpClient.get(captureAny())).captured;
      final uri = captured.cast<Uri>().firstWhere(
        (u) => u.path.contains('forecast'),
      );
      expect(uri.origin, 'https://api.open-meteo.com');
      expect(uri.path, '/v1/forecast');
      expect(uri.queryParameters['latitude'], '1.0');
      expect(uri.queryParameters['longitude'], '2.0');
      expect(
        uri.queryParameters['current'],
        'temperature_2m,apparent_temperature,relative_humidity_2m,'
        'wind_speed_10m,surface_pressure,weather_code,is_day',
      );
      expect(
        uri.queryParameters['daily'],
        'sunset,uv_index_max,temperature_2m_max,temperature_2m_min,'
        'weather_code',
      );
      expect(uri.queryParameters['timezone'], 'auto');
      expect(uri.queryParameters['forecast_days'], '4');
    });

    test(
      'attaches the Nominatim locality when reverse geocoding succeeds',
      () async {
        stubHttp(
          forecastBody: _fullBody(),
          nominatimBody: jsonEncode({
            'name': 'Sandub',
            'address': {'village': 'Sandub', 'country': 'Qatar'},
          }),
        );

        final result = await client.fetchCurrentWeather(
          latitude: 25.276987,
          longitude: 55.296249,
        );

        expect(result.placeName, 'Sandub');

        final captured = verify(
          () => httpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured;
        final uri = captured.cast<Uri>().firstWhere(
          (u) => u.host.contains('nominatim'),
        );
        expect(uri.origin, 'https://nominatim.openstreetmap.org');
        expect(uri.path, '/reverse');
        expect(uri.queryParameters['lat'], '25.276987');
        expect(uri.queryParameters['lon'], '55.296249');
        expect(uri.queryParameters['format'], 'jsonv2');
      },
    );

    test('still returns weather when reverse geocoding fails', () async {
      stubHttp(
        forecastBody: _fullBody(),
        nominatimBody: 'server error',
        nominatimStatus: 500,
      );

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.temperatureCelsius, 21.4);
      expect(result.placeName, isNull);
    });

    test('still returns weather when reverse geocoding throws', () async {
      stubHttp(
        forecastBody: _fullBody(),
        nominatimThrow: Exception('nominatim down'),
      );

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.temperatureCelsius, 21.4);
      expect(result.placeName, isNull);
    });

    test('throws WeatherFetchException on a non-200 status', () async {
      stubResponse('server error', 500);

      expect(
        () => client.fetchCurrentWeather(latitude: 1, longitude: 2),
        throwsA(isA<WeatherFetchException>()),
      );
    });

    test('throws WeatherFetchException on malformed JSON', () async {
      stubResponse('not json');

      expect(
        () => client.fetchCurrentWeather(latitude: 1, longitude: 2),
        throwsA(isA<WeatherFetchException>()),
      );
    });

    test(
      'throws WeatherFetchException when temperature_2m is missing',
      () async {
        stubResponse('{"current": {"weather_code": 0, "is_day": 1}}');

        expect(
          () => client.fetchCurrentWeather(latitude: 1, longitude: 2),
          throwsA(isA<WeatherFetchException>()),
        );
      },
    );

    test('throws WeatherFetchException when weather_code is missing', () async {
      stubResponse('{"current": {"temperature_2m": 21.4, "is_day": 1}}');

      expect(
        () => client.fetchCurrentWeather(latitude: 1, longitude: 2),
        throwsA(isA<WeatherFetchException>()),
      );
    });

    test('throws WeatherFetchException when is_day is missing', () async {
      stubResponse('{"current": {"temperature_2m": 21.4, "weather_code": 0}}');

      expect(
        () => client.fetchCurrentWeather(latitude: 1, longitude: 2),
        throwsA(isA<WeatherFetchException>()),
      );
    });

    test(
      'throws WeatherFetchException when the request itself fails',
      () async {
        when(() => httpClient.get(any())).thenThrow(Exception('network down'));

        expect(
          () => client.fetchCurrentWeather(latitude: 1, longitude: 2),
          throwsA(isA<WeatherFetchException>()),
        );
      },
    );

    test('nulls the optional fields when daily is absent entirely', () async {
      stubResponse(
        '{"current": {"temperature_2m": 18, "weather_code": 3, "is_day": 1}}',
      );

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.temperatureCelsius, 18.0);
      expect(result.condition, WeatherCondition.cloudy);
      expect(result.isDay, isTrue);
      expect(result.apparentTemperatureCelsius, isNull);
      expect(result.relativeHumidityPercent, isNull);
      expect(result.windSpeedKph, isNull);
      expect(result.surfacePressureHpa, isNull);
      expect(result.uvIndex, isNull);
      expect(result.sunset, isNull);
    });

    test('nulls the daily fields when the daily arrays are empty', () async {
      stubResponse(
        jsonEncode({
          'current': {
            'temperature_2m': 18,
            'weather_code': 3,
            'is_day': 1,
            'wind_speed_10m': 4,
          },
          'daily': {
            'sunset': <String>[],
            'uv_index_max': <double>[],
          },
        }),
      );

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.windSpeedKph, 4.0);
      expect(result.uvIndex, isNull);
      expect(result.sunset, isNull);
    });

    test('nulls optional fields that are present but null', () async {
      stubResponse(
        jsonEncode({
          'current': {
            'temperature_2m': 18,
            'weather_code': 3,
            'is_day': 1,
            'apparent_temperature': null,
            'surface_pressure': null,
          },
          'daily': {
            'sunset': [null],
            'uv_index_max': [null],
          },
        }),
      );

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.apparentTemperatureCelsius, isNull);
      expect(result.surfacePressureHpa, isNull);
      expect(result.uvIndex, isNull);
      expect(result.sunset, isNull);
    });

    test('nulls sunset when it is not a parseable datetime', () async {
      stubResponse(
        jsonEncode({
          'current': {
            'temperature_2m': 18,
            'weather_code': 3,
            'is_day': 1,
          },
          'daily': {
            'sunset': ['not a date'],
            'uv_index_max': [1],
          },
        }),
      );

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.sunset, isNull);
      expect(result.uvIndex, 1.0);
    });

    test('maps is_day 0 to isDay false', () async {
      stubResponse(_fullBody(isDay: 0));

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.isDay, isFalse);
    });

    test('parses a four-day high/low forecast from daily arrays', () async {
      stubResponse(
        jsonEncode({
          'current': {
            'temperature_2m': 36,
            'weather_code': 45,
            'is_day': 1,
          },
          'daily': {
            'time': [
              '2026-08-26',
              '2026-08-27',
              '2026-08-28',
              '2026-08-29',
            ],
            'temperature_2m_max': [40, 39, 39, 37],
            'temperature_2m_min': [21, 21, 22, 20],
            'weather_code': [45, 0, 0, 3],
            'sunset': ['2026-08-26T19:26'],
            'uv_index_max': [8],
          },
        }),
      );

      final result = await client.fetchCurrentWeather(
        latitude: 1,
        longitude: 2,
      );

      expect(result.forecastDays, hasLength(4));
      expect(result.forecastDays.first.maxCelsius, 40);
      expect(result.forecastDays.first.minCelsius, 21);
      expect(result.forecastDays.first.condition, WeatherCondition.fog);
      expect(result.forecastDays[1].condition, WeatherCondition.clear);
      expect(result.forecastDays.last.maxCelsius, 37);
    });

    group('maps weather_code to a WeatherCondition', () {
      const cases = <int, WeatherCondition>{
        0: WeatherCondition.clear,
        2: WeatherCondition.partlyCloudy,
        3: WeatherCondition.cloudy,
        45: WeatherCondition.fog,
        53: WeatherCondition.drizzle,
        61: WeatherCondition.rain,
        75: WeatherCondition.snow,
        95: WeatherCondition.thunderstorm,
      };

      for (final entry in cases.entries) {
        test('code ${entry.key} -> ${entry.value.name}', () async {
          stubResponse(_fullBody(weatherCode: entry.key));

          final result = await client.fetchCurrentWeather(
            latitude: 1,
            longitude: 2,
          );

          expect(result.condition, entry.value);
        });
      }
    });
  });

  group('OpenMeteoClient.placeNameFromNominatim', () {
    test('prefers village over the top-level name', () {
      expect(
        OpenMeteoClient.placeNameFromNominatim({
          'name': 'Municipality of Doha',
          'address': {'village': 'Sandub', 'country': 'Qatar'},
        }),
        'Sandub',
      );
    });

    test('falls back to name when address has no locality', () {
      expect(
        OpenMeteoClient.placeNameFromNominatim({'name': 'Sandub'}),
        'Sandub',
      );
    });

    test('returns null for an empty payload', () {
      expect(OpenMeteoClient.placeNameFromNominatim({}), isNull);
    });

    test('skips blank locality strings', () {
      expect(
        OpenMeteoClient.placeNameFromNominatim({
          'address': {'city': '  ', 'town': 'Al Wakrah'},
        }),
        'Al Wakrah',
      );
    });
  });
}
