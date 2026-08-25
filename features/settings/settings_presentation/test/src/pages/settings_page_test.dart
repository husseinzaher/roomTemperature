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

      expect(find.byType(SegmentedButton<Units>), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('tapping save persists the edited settings via the '
        'repository', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

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
