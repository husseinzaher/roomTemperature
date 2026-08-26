import 'package:mocktail/mocktail.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

class MockOpenMeteoClient extends Mock implements OpenMeteoClient {}

void main() {
  group('OpenMeteoWeatherRepository', () {
    late OpenMeteoClient client;
    late OpenMeteoWeatherRepository repository;

    final weather = OutsideWeather(
      temperatureCelsius: 32.1,
      condition: WeatherCondition.clear,
      isDay: true,
      apparentTemperatureCelsius: 36.4,
      relativeHumidityPercent: 55,
      windSpeedKph: 9.2,
      surfacePressureHpa: 1001.3,
      uvIndex: 7.1,
      sunset: DateTime(2026, 8, 26, 19, 26),
    );

    setUp(() {
      client = MockOpenMeteoClient();
      repository = OpenMeteoWeatherRepository(client);
    });

    test('fetches the outside weather for a location', () async {
      when(
        () => client.fetchCurrentWeather(
          latitude: 25.276987,
          longitude: 55.296249,
        ),
      ).thenAnswer((_) async => weather);

      final result = await repository.fetchOutsideWeather(
        location: const Location(latitude: 25.276987, longitude: 55.296249),
      );

      expect(result, weather);
      verify(
        () => client.fetchCurrentWeather(
          latitude: 25.276987,
          longitude: 55.296249,
        ),
      ).called(1);
    });

    test('propagates WeatherFetchException from the client', () async {
      when(
        () => client.fetchCurrentWeather(latitude: 1, longitude: 2),
      ).thenThrow(const WeatherFetchException('boom'));

      expect(
        () => repository.fetchOutsideWeather(
          location: const Location(latitude: 1, longitude: 2),
        ),
        throwsA(isA<WeatherFetchException>()),
      );
    });
  });
}
