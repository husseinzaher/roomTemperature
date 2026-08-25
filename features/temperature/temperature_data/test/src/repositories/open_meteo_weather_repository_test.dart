import 'package:mocktail/mocktail.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

class MockOpenMeteoClient extends Mock implements OpenMeteoClient {}

void main() {
  group('OpenMeteoWeatherRepository', () {
    late OpenMeteoClient client;
    late OpenMeteoWeatherRepository repository;

    setUp(() {
      client = MockOpenMeteoClient();
      repository = OpenMeteoWeatherRepository(client);
    });

    test('fetches the outside temperature for a location', () async {
      when(
        () => client.fetchCurrentTemperatureCelsius(
          latitude: 25.276987,
          longitude: 55.296249,
        ),
      ).thenAnswer((_) async => 32.1);

      final result = await repository.fetchOutsideTemperatureCelsius(
        location: const Location(latitude: 25.276987, longitude: 55.296249),
      );

      expect(result, 32.1);
      verify(
        () => client.fetchCurrentTemperatureCelsius(
          latitude: 25.276987,
          longitude: 55.296249,
        ),
      ).called(1);
    });

    test('propagates WeatherFetchException from the client', () async {
      when(
        () => client.fetchCurrentTemperatureCelsius(
          latitude: 1,
          longitude: 2,
        ),
      ).thenThrow(const WeatherFetchException('boom'));

      expect(
        () => repository.fetchOutsideTemperatureCelsius(
          location: const Location(latitude: 1, longitude: 2),
        ),
        throwsA(isA<WeatherFetchException>()),
      );
    });
  });
}
