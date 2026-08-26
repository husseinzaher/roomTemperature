import 'package:history_domain/history_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHistoryRepository extends Mock implements IHistoryRepository {}

void main() {
  group('GetHistoryQuery', () {
    late IHistoryRepository historyRepository;
    late GetHistoryQuery query;

    setUp(() {
      historyRepository = MockHistoryRepository();
      query = GetHistoryQuery(historyRepository: historyRepository);
    });

    test('delegates to IHistoryRepository.watchHistory', () {
      final history = [
        DailyAverage(
          day: DateTime(2026),
          averageRoomTemperatureCelsius: 22,
          averageOutsideTemperatureCelsius: 18,
          sampleCount: 4,
        ),
      ];
      when(
        () => historyRepository.watchHistory(),
      ).thenAnswer((_) => Stream.value(history));

      expect(query.watch(), emits(history));
    });

    test('forwards a custom days value', () {
      when(
        () => historyRepository.watchHistory(days: 7),
      ).thenAnswer((_) => Stream.value(const <DailyAverage>[]));

      expect(query.watch(days: 7), emits(const <DailyAverage>[]));
    });
  });
}
