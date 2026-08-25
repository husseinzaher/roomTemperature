import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/temperature_presentation.dart';
import 'package:ui_kit/ui_kit.dart';

class MockTemperatureRepository extends Mock
    implements ITemperatureRepository {}

class MockWeatherRepository extends Mock implements IWeatherRepository {}

void main() {
  group('DashboardPage', () {
    late ITemperatureRepository temperatureRepository;
    late IWeatherRepository weatherRepository;
    late TemperatureCubit cubit;

    final reading = Reading(
      roomTemperatureCelsius: 24.5,
      roomTemperatureSource: RoomTemperatureSource.estimated,
      outsideTemperatureCelsius: 21,
      timestamp: DateTime.utc(2026, 1, 1, 12),
    );

    setUp(() async {
      temperatureRepository = MockTemperatureRepository();
      weatherRepository = MockWeatherRepository();

      when(
        () => temperatureRepository.watchLatestReading(userId: 'user-1'),
      ).thenAnswer((_) => Stream.value(reading));

      cubit = TemperatureCubit(
        userId: 'user-1',
        temperatureRepository: temperatureRepository,
        weatherRepository: weatherRepository,
        estimator: const RoomTemperatureEstimator(),
        getLocation: () async => const Location(latitude: 0, longitude: 0),
        getIndoorOffset: () => 0,
      );

      // Let the cached reading land before the widget mounts, so initState
      // does not also kick off a refresh() that would need the weather
      // repository mocked out too.
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets(
      'renders a room card and an outside card for a loaded reading',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<TemperatureCubit>.value(
              value: cubit,
              child: const DashboardPage(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(TemperatureReadingCard), findsNWidgets(2));

        final cards = tester
            .widgetList<TemperatureReadingCard>(
              find.byType(TemperatureReadingCard),
            )
            .toList();
        final temperatures = cards
            .map((card) => card.temperatureCelsius)
            .toSet();

        expect(temperatures, {24.5, 21.0});
        expect(cards.any((card) => card.isEstimated), isTrue);
        expect(cards.any((card) => !card.isEstimated), isTrue);
      },
    );
  });
}
