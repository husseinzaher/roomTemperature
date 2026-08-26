import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/src/cubit/temperature_cubit.dart';
import 'package:temperature_presentation/src/cubit/temperature_state.dart';
import 'package:temperature_presentation/src/format/weather_format.dart';
import 'package:temperature_presentation/src/widgets/backdrop_mood_mapper.dart';
import 'package:temperature_presentation/src/widgets/weather_feature_menu.dart';
import 'package:temperature_presentation/src/widgets/weather_icon.dart';
import 'package:temperature_presentation/src/widgets/weather_stats_grid.dart';
import 'package:temperature_presentation/src/widgets/weather_top_bar.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template dashboard_page}
/// The app's main screen: a full-bleed cinematic backdrop with the indoor
/// and outdoor readings, the outdoor detail grid, and onward-navigation rows
/// floating above it on glass.
///
/// Requires a [TemperatureCubit] above it in the tree (see
/// `TemperatureModule`).
/// {@endtemplate}
class DashboardPage extends StatelessWidget {
  /// {@macro dashboard_page}
  const DashboardPage({
    required this.units,
    required this.onUnitsChanged,
    super.key,
    this.onOpenSettings,
  });

  /// The unit temperatures are displayed in.
  final Units units;

  /// Called when the user switches units from the top bar.
  final ValueChanged<Units> onUnitsChanged;

  /// Called when the settings action in the top bar is tapped.
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return _DashboardView(
      units: units,
      onUnitsChanged: onUnitsChanged,
      onOpenSettings: onOpenSettings,
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({
    required this.units,
    required this.onUnitsChanged,
    required this.onOpenSettings,
  });

  final Units units;
  final ValueChanged<Units> onUnitsChanged;
  final VoidCallback? onOpenSettings;

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    // Only kick off a fetch when there's nothing to show yet; a cached
    // reading from storage is displayed immediately instead.
    final cubit = context.read<TemperatureCubit>();
    if (cubit.state.reading == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(cubit.refresh());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<TemperatureCubit>().state;
    final reading = state.reading;
    final weather = state.weather;

    final condition = weather?.condition ?? WeatherCondition.clear;
    final isDay = weather?.isDay ?? true;
    final mood = BackdropMoodMapper.moodFor(condition, isDay: isDay);

    return WeatherBackdrop(
      mood: mood,
      imageAsset: BackdropMoodMapper.assetFor(mood),
      child: Scaffold(
        // The backdrop shows through; the Scaffold only provides the
        // structure and the safe-area-aware insets.
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: context.read<TemperatureCubit>().refresh,
            backgroundColor: const Color(0xE6151B20),
            color: GlassTokens.onGlass,
            child: _Content(
              state: state,
              reading: reading,
              weather: weather,
              units: widget.units,
              onUnitsChanged: widget.onUnitsChanged,
              onOpenSettings: widget.onOpenSettings,
              l10n: l10n,
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.reading,
    required this.weather,
    required this.units,
    required this.onUnitsChanged,
    required this.onOpenSettings,
    required this.l10n,
  });

  final TemperatureState state;
  final Reading? reading;
  final OutsideWeather? weather;
  final Units units;
  final ValueChanged<Units> onUnitsChanged;
  final VoidCallback? onOpenSettings;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isRefreshing = state.status == TemperatureStatus.loading;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep the content column comfortable on tablets rather than
        // stretching the cards to full width.
        final horizontalPadding = constraints.maxWidth > 640 ? 40.0 : 18.0;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            14,
            horizontalPadding,
            // Clear the floating nav bar the app shell overlays: its own
            // height plus its bottom offset plus the system gesture inset,
            // so the last card can always be scrolled clear of it.
            124 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            WeatherTopBar(
              units: units,
              onUnitsChanged: onUnitsChanged,
              celsiusLabel: l10n.celsius,
              fahrenheitLabel: l10n.fahrenheit,
              isRefreshing: isRefreshing,
              onRefresh: context.read<TemperatureCubit>().refresh,
              onOpenSettings: onOpenSettings,
            ),
            const SizedBox(height: 30),
            if (reading == null)
              _EmptyState(state: state, l10n: l10n)
            else ...[
              GlassSectionHeader(
                label: l10n.inside,
                helpSemanticLabel: l10n.insideHelp,
                onHelpTap: () => _showHelp(
                  context,
                  title: l10n.inside,
                  body: l10n.insideHelpBody,
                  closeLabel: l10n.close,
                ),
              ),
              const SizedBox(height: 14),
              GlassTemperatureCard(
                icon: const WeatherIcon(WeatherIcons.indoor, size: 38),
                value: WeatherFormat.temperatureValue(
                  reading!.roomTemperatureCelsius,
                  units,
                ),
                unit: units.symbol,
                badge: GlassChip(
                  icon: _sourceIcon(reading!.roomTemperatureSource),
                  label: _sourceLabel(reading!.roomTemperatureSource),
                ),
              ),
              const SizedBox(height: 26),
              GlassSectionHeader(
                label: l10n.outside,
                helpSemanticLabel: l10n.outsideHelp,
                onHelpTap: () => _showHelp(
                  context,
                  title: l10n.outside,
                  body: l10n.outsideHelpBody,
                  closeLabel: l10n.close,
                ),
              ),
              const SizedBox(height: 14),
              GlassTemperatureCard(
                icon: WeatherIcon(
                  WeatherIcons.forCondition(
                    weather?.condition ?? WeatherCondition.clear,
                    isDay: weather?.isDay ?? true,
                  ),
                  size: 40,
                ),
                value: WeatherFormat.temperatureValue(
                  reading!.outsideTemperatureCelsius,
                  units,
                ),
                unit: units.symbol,
                trailingContent: WeatherStatsGrid(
                  weather: weather,
                  units: units,
                  labels: WeatherStatsLabels(
                    feelsLike: l10n.feelsLike,
                    humidity: l10n.humidity,
                    windSpeed: l10n.windSpeed,
                    pressure: l10n.pressure,
                    sunset: l10n.sunset,
                    uvIndex: l10n.uvIndex,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _UpdatedAtLabel(
                timestamp: reading!.timestamp,
                prefix: l10n.lastUpdated,
              ),
              if (state.status == TemperatureStatus.error ||
                  state.status == TemperatureStatus.sourceUnavailable)
                _InlineError(
                  message: state.errorMessage ?? l10n.errorGeneric,
                ),
              const SizedBox(height: 22),
              WeatherFeatureMenu(
                forecastLabel: l10n.fiveDayForecast,
                airQualityLabel: l10n.airQualityMeter,
                radarLabel: l10n.weatherRadar,
              ),
            ],
          ],
        );
      },
    );
  }

  IconData _sourceIcon(RoomTemperatureSource source) {
    return switch (source) {
      RoomTemperatureSource.ambientSensor => Icons.sensors_outlined,
      RoomTemperatureSource.bluetoothSensor => Icons.bluetooth_outlined,
      RoomTemperatureSource.batteryTemperature => Icons.battery_4_bar_outlined,
      RoomTemperatureSource.manual => Icons.edit_outlined,
      RoomTemperatureSource.estimated => Icons.auto_awesome_outlined,
    };
  }

  String _sourceLabel(RoomTemperatureSource source) {
    return switch (source) {
      RoomTemperatureSource.ambientSensor => 'Phone Sensor',
      RoomTemperatureSource.bluetoothSensor => 'Bluetooth Sensor',
      RoomTemperatureSource.batteryTemperature => 'Battery Temperature',
      RoomTemperatureSource.manual => 'Manual',
      RoomTemperatureSource.estimated => 'Estimated',
    };
  }

  static void _showHelp(
    BuildContext context, {
    required String title,
    required String body,
    required String closeLabel,
  }) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GlassTokens.onGlass,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: const TextStyle(
                    color: GlassTokens.onGlassMuted,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      closeLabel,
                      style: const TextStyle(color: GlassTokens.onGlass),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.state, required this.l10n});

  final TemperatureState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (state.status == TemperatureStatus.error ||
        state.status == TemperatureStatus.sourceUnavailable) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: GlassCard(
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 44,
                color: GlassTokens.onGlassMuted,
              ),
              const SizedBox(height: 14),
              Text(
                state.errorMessage ?? l10n.errorGeneric,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GlassTokens.onGlassMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.tonalIcon(
                onPressed: context.read<TemperatureCubit>().refresh,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Center(
        child: CircularProgressIndicator(color: GlassTokens.onGlass),
      ),
    );
  }
}

class _UpdatedAtLabel extends StatelessWidget {
  const _UpdatedAtLabel({required this.timestamp, required this.prefix});

  final DateTime timestamp;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$prefix: ${WeatherFormat.updatedAt(timestamp)}',
        style: const TextStyle(
          color: GlassTokens.onGlassMuted,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFFFB4A9), fontSize: 12.5),
      ),
    );
  }
}
