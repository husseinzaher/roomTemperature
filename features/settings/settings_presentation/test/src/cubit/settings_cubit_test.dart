import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/settings_presentation.dart';

class MockSettingsRepository extends Mock implements ISettingsRepository {}

void main() {
  group('SettingsCubit', () {
    late ISettingsRepository settingsRepository;

    final loadedSettings = UserSettings.defaults().copyWith(
      indoorOffsetCelsius: 1.5,
    );

    setUpAll(() {
      registerFallbackValue(UserSettings.defaults());
    });

    setUp(() {
      settingsRepository = MockSettingsRepository();
    });

    SettingsCubit buildCubit({Stream<UserSettings>? watchStream}) {
      when(
        () => settingsRepository.watchSettings(),
      ).thenAnswer((_) => watchStream ?? const Stream.empty());

      return SettingsCubit(
        settingsRepository: settingsRepository,
      );
    }

    test('initial state is loading with no settings', () async {
      final cubit = buildCubit();
      expect(cubit.state, const SettingsState.loading());
      await cubit.close();
    });

    blocTest<SettingsCubit, SettingsState>(
      'emits a loaded state when watchSettings emits',
      build: () => buildCubit(watchStream: Stream.value(loadedSettings)),
      expect: () => [SettingsState.loaded(settings: loadedSettings)],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits an error state when watchSettings errors',
      build: () => buildCubit(
        watchStream: Stream<UserSettings>.error(Exception('offline')),
      ),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.status, 'status', SettingsStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'save() optimistically emits saving then relies on the stream to '
      'confirm',
      build: buildCubit,
      setUp: () {
        when(
          () => settingsRepository.updateSettings(
            settings: loadedSettings,
          ),
        ).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.save(loadedSettings),
      expect: () => [SettingsState.saving(settings: loadedSettings)],
      verify: (_) {
        verify(
          () => settingsRepository.updateSettings(
            settings: loadedSettings,
          ),
        ).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'save() emits an error state when the write throws, preserving the '
      'attempted settings',
      build: buildCubit,
      setUp: () {
        when(
          () => settingsRepository.updateSettings(
            settings: loadedSettings,
          ),
        ).thenThrow(Exception('network down'));
      },
      act: (cubit) => cubit.save(loadedSettings),
      expect: () => [
        SettingsState.saving(settings: loadedSettings),
        isA<SettingsState>()
            .having((s) => s.status, 'status', SettingsStatus.error)
            .having((s) => s.settings, 'settings', loadedSettings)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });
}
