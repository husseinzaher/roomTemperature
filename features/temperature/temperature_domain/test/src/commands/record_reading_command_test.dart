import 'package:mocktail/mocktail.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

class MockTemperatureRepository extends Mock
    implements ITemperatureRepository {}

void main() {
  group('RecordReadingCommand', () {
    late ITemperatureRepository temperatureRepository;
    late RecordReadingCommand command;

    setUp(() {
      temperatureRepository = MockTemperatureRepository();
      command = RecordReadingCommand(
        temperatureRepository: temperatureRepository,
      );
    });

    test('delegates to ITemperatureRepository.recordReading', () async {
      final reading = Reading(
        roomTemperatureCelsius: 22,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: 18,
        timestamp: DateTime(2026),
      );
      when(
        () => temperatureRepository.recordReading(
          userId: 'user-1',
          reading: reading,
        ),
      ).thenAnswer((_) async {});

      await command.execute(userId: 'user-1', reading: reading);

      verify(
        () => temperatureRepository.recordReading(
          userId: 'user-1',
          reading: reading,
        ),
      ).called(1);
    });

    test('propagates errors from the repository', () async {
      final reading = Reading(
        roomTemperatureCelsius: 22,
        roomTemperatureSource: RoomTemperatureSource.ambientSensor,
        outsideTemperatureCelsius: 18,
        timestamp: DateTime(2026),
      );
      when(
        () => temperatureRepository.recordReading(
          userId: 'user-1',
          reading: reading,
        ),
      ).thenThrow(Exception('boom'));

      expect(
        () => command.execute(userId: 'user-1', reading: reading),
        throwsException,
      );
    });
  });
}
