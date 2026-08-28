import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/history_presentation.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:provider/provider.dart';
import 'package:room_temperature_app/home/home_widget_labels.dart';
import 'package:room_temperature_app/services/data_refresh_coordinator.dart';
import 'package:room_temperature_app/services/indoor_temperature_service.dart';
import 'package:room_temperature_app/services/location_service.dart';
import 'package:room_temperature_app/services/notifications_background.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/settings_presentation.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/temperature_presentation.dart';
import 'package:ui_kit/ui_kit.dart';

/// The local-only app shell: the dashboard, history, and settings tabs behind
/// a floating glass navigation bar, wiring the settings, temperature,
/// history, and (headless) notification-threshold features together.
class HomeShellPage extends StatelessWidget {
  /// Creates a [HomeShellPage].
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsModule(
      settingsRepository: context.read<ISettingsRepository>(),
      child: const _TemperatureAndHistoryScope(),
    );
  }
}

class _TemperatureAndHistoryScope extends StatelessWidget {
  const _TemperatureAndHistoryScope();

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return TemperatureModule(
      temperatureRepository: context.read<ITemperatureRepository>(),
      weatherRepository: context.read<IWeatherRepository>(),
      estimator: const RoomTemperatureEstimator(),
      getLocation: () => context.read<LocationService>().getCurrentLocation(),
      getIndoorOffset: () =>
          settingsCubit.state.settings?.indoorOffsetCelsius ?? 0,
      resolveIndoorTemperature: () {
        final settings =
            settingsCubit.state.settings ?? UserSettings.defaults();
        return context.read<IndoorTemperatureService>().resolve(
          preference: settings.indoorTemperaturePreference,
        );
      },
      child: HistoryModule(
        historyRepository: context.read<IHistoryRepository>(),
        child: const _HomeTabsView(),
      ),
    );
  }
}

class _HomeTabsView extends StatefulWidget {
  const _HomeTabsView();

  @override
  State<_HomeTabsView> createState() => _HomeTabsViewState();
}

class _HomeTabsViewState extends State<_HomeTabsView> {
  static const _dashboardIndex = 0;

  int _index = _dashboardIndex;
  late final DataRefreshCoordinator _coordinator;

  @override
  void initState() {
    super.initState();
    final settingsCubit = context.read<SettingsCubit>();
    final temperatureCubit = context.read<TemperatureCubit>();
    final indoorService = context.read<IndoorTemperatureService>();
    final homeWidget = context.read<HomeWidgetBridge>();

    _coordinator = DataRefreshCoordinator(
      readInterval: () => RefreshInterval.clamp(
        settingsCubit.state.settings?.refreshInterval ??
            RefreshInterval.defaultInterval,
      ),
      intervalChanges: settingsCubit.stream.map(
        (state) => RefreshInterval.clamp(
          state.settings?.refreshInterval ?? RefreshInterval.defaultInterval,
        ),
      ),
      publishRefresh: temperatureCubit.refresh,
      sampleIndoor: () async {
        final settings =
            settingsCubit.state.settings ?? UserSettings.defaults();
        await indoorService.resolve(
          preference: settings.indoorTemperaturePreference,
        );
      },
      rescheduleBackground: registerBackgroundDataRefresh,
      persistWidgetInterval: (interval) {
        return homeWidget.saveRefreshIntervalMinutes(interval.inMinutes);
      },
    );

    _coordinator.seedLastUpdate(
      temperatureCubit.state.reading?.timestamp,
      hasWeather: temperatureCubit.state.weather != null,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_coordinator.attach());
      }
    });
  }

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  void _onUnitsChanged(Units units) {
    final cubit = context.read<SettingsCubit>();
    final current = cubit.state.settings;
    if (current == null || current.units == units) return;
    unawaited(cubit.save(current.copyWith(units: units)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final units =
        context.watch<SettingsCubit>().state.settings?.units ?? Units.celsius;
    final refreshInterval = RefreshInterval.clamp(
      context.watch<SettingsCubit>().state.settings?.refreshInterval ??
          RefreshInterval.defaultInterval,
    );

    return ChangeNotifierProvider<DataRefreshCoordinator>.value(
      value: _coordinator,
      child: BlocListener<TemperatureCubit, TemperatureState>(
      listener: _pushReadingToHomeWidget,
      // Transparent Material so text in the floating nav bar resolves a
      // Material ancestor (without one, Flutter paints a debug underline
      // under every label) while the backdrop still shows through.
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Each tab paints its own full-bleed background, so the tab body
            // fills the whole window rather than sitting inside a Scaffold
            // that reserves space for a bottom bar.
            Positioned.fill(
              child: IndexedStack(
                index: _index,
                children: [
                  DashboardPage(
                    units: units,
                    refreshInterval: refreshInterval,
                    onUnitsChanged: _onUnitsChanged,
                    onOpenSettings: () => setState(() => _index = 2),
                  ),
                  const _TabScaffold(child: HistoryPage()),
                  _TabScaffold(
                    child: SettingsPage(
                      loadIndoorTemperatureSourceAvailability: () async {
                        final availability = await context
                            .read<IndoorTemperatureService>()
                            .availability();
                        return {
                          IndoorTemperaturePreference.automatic: true,
                          IndoorTemperaturePreference.ambientSensor:
                              availability[IndoorTemperatureSource
                                  .ambientSensor] ??
                              false,
                          IndoorTemperaturePreference.bluetoothSensor:
                              availability[IndoorTemperatureSource
                                  .bluetoothSensor] ??
                              false,
                          IndoorTemperaturePreference.batteryTemperature:
                              availability[IndoorTemperatureSource
                                  .batteryTemperature] ??
                              false,
                          IndoorTemperaturePreference.manual:
                              availability[IndoorTemperatureSource.manual] ??
                              false,
                          IndoorTemperaturePreference.estimated:
                              availability[IndoorTemperatureSource.estimated] ??
                              true,
                        };
                      },
                      indoorCalibration: IndoorCalibrationHost(
                        load: () async {
                          final service = context
                              .read<IndoorTemperatureService>();
                          await service.resolve(
                            preference: IndoorTemperaturePreference.estimated,
                          );
                          final estimate = service.lastEstimate;
                          final profile = await service.thermalProvider?.store
                              .loadProfile();
                          return IndoorCalibrationView(
                            estimateCelsius: estimate?.temperatureCelsius,
                            confidence: estimate?.confidence,
                            statusLabel:
                                estimate?.debug.statusLabel ??
                                'Learning baseline',
                            hasCalibration: profile?.hasCalibration ?? false,
                            debugText: kDebugMode
                                ? [
                                    service.lastDebug?.format(),
                                    _coordinator.state.debugSummary(),
                                  ].whereType<String>().join('\n\n')
                                : null,
                          );
                        },
                        calibrate: (actual) {
                          return context
                              .read<IndoorTemperatureService>()
                              .calibrate(actualRoomCelsius: actual);
                        },
                        reset: () {
                          return context
                              .read<IndoorTemperatureService>()
                              .resetCalibration();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
              child: GlassNavBar(
                selectedIndex: _index,
                onSelected: (index) => setState(() => _index = index),
                items: [
                  GlassNavItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: l10n.dashboard,
                  ),
                  GlassNavItem(
                    icon: Icons.history_outlined,
                    selectedIcon: Icons.history,
                    label: l10n.history,
                  ),
                  GlassNavItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: l10n.settings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _pushReadingToHomeWidget(
    BuildContext context,
    TemperatureState state,
  ) {
    final reading = state.reading;
    if (reading == null) {
      return;
    }
    if (state.status != TemperatureStatus.loaded) {
      return;
    }

    final settings =
        context.read<SettingsCubit>().state.settings ?? UserSettings.defaults();

    unawaited(
      syncHomeWidget(
        bridge: context.read<HomeWidgetBridge>(),
        reading: reading,
        settings: settings,
        weather: state.weather,
      ),
    );
    _coordinator.recordSuccessfulUpdate(
      at: reading.timestamp,
      outdoor: state.weather != null,
    );
  }
}

/// Wraps the history and settings tabs so they share the dashboard's
/// cinematic backdrop and leave room for the floating nav bar.
class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WeatherBackdrop(
      mood: BackdropMood.overcast,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 92),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: child,
        ),
      ),
    );
  }
}
