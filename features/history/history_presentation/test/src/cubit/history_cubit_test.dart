import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/history_presentation.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoryRepository extends Mock implements IHistoryRepository {}

void main() {
  group('HistoryCubit', () {
    late IHistoryRepository historyRepository;

    final items = [
      DailyAverage(
        day: DateTime(2026, 1, 2),
        averageRoomTemperatureCelsius: 23,
        averageOutsideTemperatureCelsius: 19,
        sampleCount: 5,
      ),
      DailyAverage(
        day: DateTime(2026),
        averageRoomTemperatureCelsius: 22,
        averageOutsideTemperatureCelsius: 18,
        sampleCount: 4,
      ),
    ];

    setUp(() {
      historyRepository = MockHistoryRepository();
    });

    HistoryCubit buildCubit({
      Stream<List<DailyAverage>>? watchStream,
      int days = 30,
    }) {
      when(
        () => historyRepository.watchHistory(userId: 'user-1', days: days),
      ).thenAnswer((_) => watchStream ?? const Stream.empty());

      return HistoryCubit(
        userId: 'user-1',
        historyRepository: historyRepository,
        days: days,
      );
    }

    test('initial state is loading with no items', () async {
      final cubit = buildCubit();
      expect(cubit.state, const HistoryState.loading());
      await cubit.close();
    });

    test('subscribes with the given userId and days', () {
      final cubit = buildCubit(days: 7);
      addTearDown(cubit.close);

      verify(
        () => historyRepository.watchHistory(userId: 'user-1', days: 7),
      ).called(1);
    });

    blocTest<HistoryCubit, HistoryState>(
      'emits a loaded state when the repository stream emits history',
      build: () => buildCubit(watchStream: Stream.value(items)),
      expect: () => [HistoryState.loaded(items: items)],
    );

    blocTest<HistoryCubit, HistoryState>(
      'emits an error state when the repository stream errors',
      build: () => buildCubit(
        watchStream: Stream.error(Exception('firestore down')),
      ),
      expect: () => [
        isA<HistoryState>()
            .having((s) => s.status, 'status', HistoryStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    group('when the stream errors after a successful load', () {
      late StreamController<List<DailyAverage>> controller;

      setUp(() {
        controller = StreamController<List<DailyAverage>>();
        when(
          () => historyRepository.watchHistory(userId: 'user-1'),
        ).thenAnswer((_) => controller.stream);
      });

      tearDown(() => controller.close());

      blocTest<HistoryCubit, HistoryState>(
        'preserves the previously loaded items in the error state',
        build: () => HistoryCubit(
          userId: 'user-1',
          historyRepository: historyRepository,
        ),
        act: (cubit) async {
          controller.add(items);
          await Future<void>.delayed(Duration.zero);
          controller.addError(Exception('firestore down'));
        },
        expect: () => [
          HistoryState.loaded(items: items),
          isA<HistoryState>()
              .having((s) => s.status, 'status', HistoryStatus.error)
              .having((s) => s.items, 'items', items),
        ],
      );
    });
  });
}
