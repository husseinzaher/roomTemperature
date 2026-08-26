import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_domain/settings_domain.dart';
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

    final weather = OutsideWeather(
      temperatureCelsius: 21,
      condition: WeatherCondition.clear,
      isDay: true,
      apparentTemperatureCelsius: 19.6,
      relativeHumidityPercent: 36,
      windSpeedKph: 30,
      surfacePressureHpa: 1007,
      uvIndex: 2,
      sunset: DateTime(2026, 8, 26, 19, 26),
    );

    setUpAll(() {
      registerFallbackValue(const Location(latitude: 0, longitude: 0));
      registerFallbackValue(
        Reading(
          roomTemperatureCelsius: 0,
          roomTemperatureSource: RoomTemperatureSource.estimated,
          outsideTemperatureCelsius: 0,
          timestamp: DateTime.utc(2026),
        ),
      );
    });

    setUp(() async {
      temperatureRepository = MockTemperatureRepository();
      weatherRepository = MockWeatherRepository();

      when(
        () => temperatureRepository.watchLatestReading(),
      ).thenAnswer((_) => Stream.value(reading));
      when(
        () => temperatureRepository.recordReading(
          reading: any(named: 'reading'),
        ),
      ).thenAnswer((_) async {});

      cubit = TemperatureCubit(
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

    Widget buildSubject({Units units = Units.celsius}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider<TemperatureCubit>.value(
          value: cubit,
          child: DashboardPage(units: units, onUnitsChanged: (_) {}),
        ),
      );
    }

    testWidgets('renders an inside and an outside temperature card', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(GlassTemperatureCard), findsNWidgets(2));

      final values = tester
          .widgetList<GlassTemperatureCard>(find.byType(GlassTemperatureCard))
          .map((card) => card.value)
          .toList();

      // Formatted to one decimal — never raw float precision.
      expect(values, containsAll(<String>['24.5', '21.0']));
    });

    testWidgets('labels the indoor reading as estimated', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Estimated'), findsOneWidget);
    });

    testWidgets('labels a battery reading as Battery Temperature', (
      tester,
    ) async {
      cubit.emit(
        TemperatureState.loaded(
          reading: Reading(
            roomTemperatureCelsius: 36.5,
            roomTemperatureSource: RoomTemperatureSource.batteryTemperature,
            outsideTemperatureCelsius: 21,
            timestamp: DateTime.utc(2026, 1, 1, 12),
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('36.5'), findsOneWidget);
      expect(find.text('Battery Temperature'), findsOneWidget);
      expect(find.text('Room Temperature'), findsNothing);
      expect(find.text('Phone Sensor'), findsNothing);
    });

    testWidgets('labels an ambient reading as Phone Sensor', (tester) async {
      cubit.emit(
        TemperatureState.loaded(
          reading: Reading(
            roomTemperatureCelsius: 20.4,
            roomTemperatureSource: RoomTemperatureSource.ambientSensor,
            outsideTemperatureCelsius: 21,
            timestamp: DateTime.utc(2026, 1, 1, 12),
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('20.4'), findsOneWidget);
      expect(find.text('Phone Sensor'), findsOneWidget);
    });

    testWidgets('renders both section headers', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('INSIDE'), findsOneWidget);
      expect(find.text('OUTSIDE'), findsOneWidget);
    });

    testWidgets('renders all six stat tiles', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(GlassStatTile), findsNWidgets(6));
      expect(find.text('Feels like'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Wind Speed'), findsOneWidget);
      expect(find.text('Pressure'), findsOneWidget);
      expect(find.text('Sunset'), findsOneWidget);
      expect(find.text('UV Index'), findsOneWidget);
    });

    testWidgets(
      'stat tiles show placeholders when no live weather is available',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        // The cached reading carries no OutsideWeather, so every detail
        // tile falls back to the placeholder rather than the grid collapsing.
        expect(find.text('—'), findsNWidgets(6));
      },
    );

    testWidgets('stat tiles show formatted values once weather arrives', (
      tester,
    ) async {
      when(
        () => weatherRepository.fetchOutsideWeather(
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) async => weather);

      await tester.pumpWidget(buildSubject());
      await cubit.refresh();
      await tester.pump();

      expect(find.text('36 %'), findsOneWidget);
      expect(find.text('30 km/h'), findsOneWidget);
      expect(find.text('1007 hPa'), findsOneWidget);
      expect(find.text('07:26 PM'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('19.6 °C'), findsOneWidget);
    });

    testWidgets('converts temperatures when the unit is Fahrenheit', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(units: Units.fahrenheit));
      await tester.pump();

      final values = tester
          .widgetList<GlassTemperatureCard>(find.byType(GlassTemperatureCard))
          .map((card) => card.value)
          .toList();

      // 24.5 C -> 76.1 F, 21 C -> 69.8 F
      expect(values, containsAll(<String>['76.1', '69.8']));
    });

    testWidgets('renders the three onward-navigation rows', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // The rows sit below the fold; drag the list up so the lazily-built
      // trailing children are created.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.byType(GlassFeatureRow), findsNWidgets(3));
      expect(find.text('5-Day Forecast'), findsOneWidget);
      expect(find.text('Air Quality Meter'), findsOneWidget);
      expect(find.text('Weather Radar'), findsOneWidget);
    });

    testWidgets('shows the pin and locality when weather has a place name', (
      tester,
    ) async {
      cubit.emit(
        TemperatureState.loaded(
          reading: reading,
          weather: const OutsideWeather(
            temperatureCelsius: 21,
            condition: WeatherCondition.clear,
            isDay: true,
            placeName: 'Sandub',
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Sandub'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('hides the location row when weather has no place name', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    });
  });
}
