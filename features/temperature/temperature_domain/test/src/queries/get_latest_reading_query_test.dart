import 'package:mocktail/mocktail.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

class MockTemperatureRepository extends Mock
    implements ITemperatureRepository {}

void main() {
  group('GetLatestReadingQuery', () {
    late ITemperatureRepository temperatureRepository;
    late GetLatestReadingQuery query;

    setUp(() {
      temperatureRepository = MockTemperatureRepository();
      query = GetLatestReadingQuery(
        temperatureRepository: temperatureRepository,
      );
    });

    test('delegates to ITemperatureRepository.watchLatestReading', () {
      final reading = Reading(
        roomTemperatureCelsius: 22,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: 18,
        timestamp: DateTime(2026),
      );
      when(
        () => temperatureRepository.watchLatestReading(userId: 'user-1'),
      ).thenAnswer((_) => Stream.value(reading));

      expect(
        query.watch(userId: 'user-1'),
        emits(reading),
      );
    });

    test('emits null when there is no reading yet', () {
      when(
        () => temperatureRepository.watchLatestReading(userId: 'user-1'),
      ).thenAnswer((_) => Stream.value(null));

      expect(
        query.watch(userId: 'user-1'),
        emits(null),
      );
    });
  });
}
