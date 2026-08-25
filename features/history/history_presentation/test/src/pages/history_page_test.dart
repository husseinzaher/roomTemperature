import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/history_presentation.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoryRepository extends Mock implements IHistoryRepository {}

void main() {
  group('HistoryPage', () {
    late IHistoryRepository historyRepository;

    Widget buildSubject(HistoryCubit cubit) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<HistoryCubit>.value(
          value: cubit,
          child: const HistoryPage(),
        ),
      );
    }

    setUp(() {
      historyRepository = MockHistoryRepository();
    });

    testWidgets('renders a chart and a list tile per day for loaded history', (
      tester,
    ) async {
      final items = [
        DailyAverage(
          day: DateTime(2026, 1, 3),
          averageRoomTemperatureCelsius: 24,
          averageOutsideTemperatureCelsius: 20,
          sampleCount: 6,
        ),
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
      when(
        () => historyRepository.watchHistory(userId: 'user-1'),
      ).thenAnswer((_) => Stream.value(items));

      final cubit = HistoryCubit(
        userId: 'user-1',
        historyRepository: historyRepository,
      );
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pump();

      expect(find.byType(ListTile), findsNWidgets(items.length));
      expect(find.text(items.first.isoDateKey), findsOneWidget);
      expect(find.text(items.last.isoDateKey), findsOneWidget);
    });

    testWidgets('shows the empty state when there is no history yet', (
      tester,
    ) async {
      when(
        () => historyRepository.watchHistory(userId: 'user-1'),
      ).thenAnswer((_) => Stream.value(const <DailyAverage>[]));

      final cubit = HistoryCubit(
        userId: 'user-1',
        historyRepository: historyRepository,
      );
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      await tester.pumpWidget(buildSubject(cubit));
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
      final capturedContext = tester.element(find.byType(HistoryPage));
      expect(find.text(capturedContext.l10n.noHistoryYet), findsOneWidget);
    });

    testWidgets('shows a loading indicator before the first emission', (
      tester,
    ) async {
      when(
        () => historyRepository.watchHistory(userId: 'user-1'),
      ).thenAnswer((_) => const Stream.empty());

      final cubit = HistoryCubit(
        userId: 'user-1',
        historyRepository: historyRepository,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
