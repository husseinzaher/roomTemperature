import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('OpenMeteoClient', () {
    late http.Client httpClient;
    late OpenMeteoClient client;

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://api.open-meteo.com'));
    });

    setUp(() {
      httpClient = MockHttpClient();
      client = OpenMeteoClient(httpClient: httpClient);
    });

    test('parses the current temperature from a successful response', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          '{"current": {"temperature_2m": 21.4}}',
          200,
        ),
      );

      final result = await client.fetchCurrentTemperatureCelsius(
        latitude: 25.276987,
        longitude: 55.296249,
      );

      expect(result, 21.4);
    });

    test('requests the expected Open-Meteo URL', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response('{"current": {"temperature_2m": 10}}', 200),
      );

      await client.fetchCurrentTemperatureCelsius(latitude: 1, longitude: 2);

      final captured = verify(() => httpClient.get(captureAny())).captured;
      final uri = captured.single as Uri;
      expect(uri.toString(), contains('latitude=1'));
      expect(uri.toString(), contains('longitude=2'));
      expect(uri.toString(), contains('current=temperature_2m'));
    });

    test('throws WeatherFetchException on a non-200 status', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response('server error', 500),
      );

      expect(
        () => client.fetchCurrentTemperatureCelsius(latitude: 1, longitude: 2),
        throwsA(isA<WeatherFetchException>()),
      );
    });

    test('throws WeatherFetchException on malformed JSON', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response('not json', 200),
      );

      expect(
        () => client.fetchCurrentTemperatureCelsius(latitude: 1, longitude: 2),
        throwsA(isA<WeatherFetchException>()),
      );
    });

    test(
      'throws WeatherFetchException when temperature_2m is missing',
      () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response('{"current": {}}', 200),
        );

        expect(
          () =>
              client.fetchCurrentTemperatureCelsius(latitude: 1, longitude: 2),
          throwsA(isA<WeatherFetchException>()),
        );
      },
    );

    test(
      'throws WeatherFetchException when the request itself fails',
      () async {
        when(() => httpClient.get(any())).thenThrow(Exception('network down'));

        expect(
          () =>
              client.fetchCurrentTemperatureCelsius(latitude: 1, longitude: 2),
          throwsA(isA<WeatherFetchException>()),
        );
      },
    );
  });
}
