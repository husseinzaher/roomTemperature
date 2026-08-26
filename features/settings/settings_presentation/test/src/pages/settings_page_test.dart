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
        () => settingsRepository.watchSettings(userId: 'user-1'),
      ).thenAnswer((_) => Stream.value(settings));
      when(
        () => settingsRepository.updateSettings(
          userId: any(named: 'userId'),
          settings: any(named: 'settings'),
        ),
      ).thenAnswer((_) async {});

      cubit = SettingsCubit(
        userId: 'user-1',
        settingsRepository: settingsRepository,
      );

      // Let the loaded settings land before the widget mounts.
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() async {
      await cubit.close();
    });

    Widget buildSubject() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<SettingsCubit>.value(
          value: cubit,
          child: const SettingsPage(),
        ),
      );
    }

    testWidgets('renders the units toggle, threshold controls, offset '
        'slider, and save button for a loaded state', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(GlassSegmentedToggle), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
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
      expect(find.text('Estimated'), findsOneWidget);
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

    testWidgets('tapping save persists the edited settings via the '
        'repository', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.scrollUntilVisible(find.byType(PrimaryButton), 200);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      verify(
        () => settingsRepository.updateSettings(
          userId: 'user-1',
          settings: settings,
        ),
      ).called(1);
    });
  });
}
