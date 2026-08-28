import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/settings_presentation.dart';
import 'package:ui_kit/ui_kit.dart';

class MockSettingsRepository extends Mock implements ISettingsRepository {}

void main() {
  group('SettingsPage', () {
    late ISettingsRepository settingsRepository;
    late SettingsCubit cubit;

    final settings = UserSettings.defaults().copyWith(
      indoorOffsetCelsius: 1.5,
    );

    setUpAll(() {
      registerFallbackValue(UserSettings.defaults());
    });

    setUp(() async {
      settingsRepository = MockSettingsRepository();

      when(
        () => settingsRepository.watchSettings(),
      ).thenAnswer((_) => Stream.value(settings));
      when(
        () => settingsRepository.updateSettings(
          settings: any(named: 'settings'),
        ),
      ).thenAnswer((_) async {});

      cubit = SettingsCubit(settingsRepository: settingsRepository);

      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() async {
      await cubit.close();
    });

    Widget buildSubject({
      IndoorCalibrationHost? indoorCalibration,
      PlaceHistoryHost? placeHistory,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider<SettingsCubit>.value(
          value: cubit,
          child: SettingsPage(
            indoorCalibration: indoorCalibration,
            placeHistory: placeHistory,
          ),
        ),
      );
    }

    testWidgets('renders the units toggle, threshold controls, and save '
        'button for a loaded state', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(GlassSegmentedToggle), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
      await tester.scrollUntilVisible(find.byType(PrimaryButton), 200);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('renders indoor temperature source radios', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('INDOOR TEMPERATURE SOURCE'), findsOneWidget);
      expect(
        find.byType(GlassSelectTile),
        findsNWidgets(IndoorTemperaturePreference.values.length),
      );
      expect(find.text('Automatic'), findsOneWidget);
      expect(find.text('Phone Ambient Sensor'), findsOneWidget);
      expect(find.text('Bluetooth Sensor'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Battery Temperature'), findsOneWidget);
      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Local estimate'), findsOneWidget);
    });

    testWidgets('shows the battery warning when battery is selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Battery Temperature'));
      await tester.tap(find.text('Battery Temperature'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Battery temperature is the temperature of the phone battery',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders indoor calibration when a host is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          indoorCalibration: IndoorCalibrationHost(
            load: () async => const IndoorCalibrationView(
              estimateCelsius: 25,
            ),
            calibrate: (_) async => (saved: true, poorConditions: false),
            reset: () async {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('tapping save persists the edited settings via the '
        'repository', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.scrollUntilVisible(find.byType(PrimaryButton), 200);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      verify(
        () => settingsRepository.updateSettings(settings: settings),
      ).called(1);
    });

    testWidgets('renders place history controls when a host is provided', (
      tester,
    ) async {
      var enabledCalls = 0;
      var deleteCalls = 0;
      var openCalls = 0;

      await tester.pumpWidget(
        buildSubject(
          placeHistory: PlaceHistoryHost(
            onOpenPlaces: () => openCalls++,
            onDeleteAll: () async => deleteCalls++,
            onEnabledChanged: ({required enabled}) async => enabledCalls++,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('LOCATION HISTORY'), findsOneWidget);
      expect(find.byKey(const Key('place-history-switch')), findsOneWidget);

      await tester.tap(find.byKey(const Key('place-history-switch')));
      await tester.pump();
      expect(enabledCalls, 1);

      await tester.tap(find.text('View places'));
      await tester.pump();
      expect(openCalls, 1);

      await tester.tap(find.text('Delete all place history'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('every stored place and visit'),
        findsOneWidget,
      );
      await tester.tap(find.text('Delete all place history').last);
      await tester.pumpAndSettle();
      expect(deleteCalls, 1);
    });

    testWidgets('shows the default 15-minute refresh interval', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('REFRESH INTERVAL'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
    });

    testWidgets('picking 1 minute persists immediately', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.byKey(const Key('refresh-interval-tile')));
      await tester.pumpAndSettle();

      expect(find.text('Select refresh interval'), findsOneWidget);
      expect(find.text('1 minute'), findsOneWidget);
      expect(find.text('5 minutes'), findsOneWidget);

      await tester.tap(find.text('1 minute'));
      await tester.pumpAndSettle();

      verify(
        () => settingsRepository.updateSettings(
          settings: settings.copyWith(
            refreshInterval: const Duration(minutes: 1),
          ),
        ),
      ).called(1);
    });
  });
}
