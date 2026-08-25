import 'package:flutter_test/flutter_test.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/history_presentation.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoryRepository extends Mock implements IHistoryRepository {}

void main() {
  test('constructing HistoryCubit with empty stream does not hang', () async {
    final repo = MockHistoryRepository();
    when(
      () => repo.watchHistory(userId: 'user-1', days: 30),
    ).thenAnswer((_) => Stream.value(const <DailyAverage>[]));

    final cubit = HistoryCubit(userId: 'user-1', historyRepository: repo);
    await Future<void>.delayed(Duration.zero);
    print('state: ${cubit.state}');
    await cubit.close();
  });
}
