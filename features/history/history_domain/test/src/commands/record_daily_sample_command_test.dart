import 'package:history_domain/history_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHistoryRepository extends Mock implements IHistoryRepository {}

void main() {
  group('RecordDailySampleCommand', () {
    late IHistoryRepository historyRepository;
    late RecordDailySampleCommand command;

    setUp(() {
      historyRepository = MockHistoryRepository();
      command = RecordDailySampleCommand(
        historyRepository: historyRepository,
      );
    });

    test('delegates to IHistoryRepository.recordSample', () async {
      final day = DateTime(2026);
      when(
        () => historyRepository.recordSample(
          userId: 'user-1',
          day: day,
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        ),
      ).thenAnswer((_) async {});

      await command.execute(
        userId: 'user-1',
        day: day,
        roomTemperatureCelsius: 22,
        outsideTemperatureCelsius: 18,
      );

      verify(
        () => historyRepository.recordSample(
          userId: 'user-1',
          day: day,
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        ),
      ).called(1);
    });

    test('propagates errors from the repository', () async {
      final day = DateTime(2026);
      when(
        () => historyRepository.recordSample(
          userId: 'user-1',
          day: day,
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        ),
      ).thenThrow(Exception('boom'));

      expect(
        () => command.execute(
          userId: 'user-1',
          day: day,
          roomTemperatureCelsius: 22,
          outsideTemperatureCelsius: 18,
        ),
        throwsException,
      );
    });
  });
}
