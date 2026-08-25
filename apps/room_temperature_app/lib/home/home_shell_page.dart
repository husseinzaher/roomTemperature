import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:history_domain/history_domain.dart';
import 'package:history_presentation/history_presentation.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:room_temperature_app/services/ambient_sensor_service.dart';
import 'package:room_temperature_app/services/location_service.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/settings_presentation.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/temperature_presentation.dart';

/// The signed-in app shell: a bottom-navigation scaffold over the
/// dashboard, history, and settings tabs, wiring the settings, temperature,
/// history, and (headless) notification-threshold features together for
/// the current user.
class HomeShellPage extends StatelessWidget {
  /// Creates a [HomeShellPage].
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthStatusCubit>().state?.uid;
    if (userId == null) {
      // The router's redirect logic keeps unauthenticated users off this
      // route; this is just a defensive fallback during the brief moment
      // a sign-out is propagating.
      return const SizedBox.shrink();
    }

    return SettingsModule(
      userId: userId,
      settingsRepository: context.read<ISettingsRepository>(),
      child: _TemperatureAndHistoryScope(userId: userId),
    );
  }
}

class _TemperatureAndHistoryScope extends StatelessWidget {
  const _TemperatureAndHistoryScope({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return TemperatureModule(
      userId: userId,
      temperatureRepository: context.read<ITemperatureRepository>(),
      weatherRepository: context.read<IWeatherRepository>(),
      estimator: const RoomTemperatureEstimator(),
      getLocation: () => context.read<LocationService>().getCurrentLocation(),
      getIndoorOffset: () =>
          settingsCubit.state.settings?.indoorOffsetCelsius ?? 0,
      readAmbientSensor: () =>
          context.read<AmbientSensorService>().readCelsius(),
      child: HistoryModule(
        userId: userId,
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
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<TemperatureCubit, TemperatureState>(
      listener: (context, state) {
        final reading = state.reading;
        if (reading == null) return;
        final settings = context.read<SettingsCubit>().state.settings;
        final threshold = settings?.threshold;
        final breached =
            threshold != null &&
            threshold.enabled &&
            (reading.roomTemperatureCelsius < threshold.minCelsius ||
                reading.roomTemperatureCelsius > threshold.maxCelsius);

        unawaited(
          context.read<HomeWidgetBridge>().updateReading(
            roomTemperatureCelsius: reading.roomTemperatureCelsius,
            outsideTemperatureCelsius: reading.outsideTemperatureCelsius,
            isEstimatedRoomTemperature: reading.isEstimated,
            thresholdBreached: breached,
            updatedAt: reading.timestamp,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleFor(_index, l10n)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l10n.logout,
              onPressed: () => context.read<SignOutCommand>().execute(),
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: const [DashboardPage(), HistoryPage(), SettingsPage()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: l10n.dashboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history),
              label: l10n.history,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(int index, AppLocalizations l10n) {
    switch (index) {
      case 1:
        return l10n.history;
      case 2:
        return l10n.settings;
      default:
        return l10n.dashboard;
    }
  }
}
