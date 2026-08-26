import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/src/cubit/settings_cubit.dart';
import 'package:settings_presentation/src/cubit/settings_state.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template settings_page}
/// Lets the user configure their display units, threshold alerts, and the
/// indoor calibration offset used by the temperature feature's
/// room-temperature estimate.
///
/// Requires a [SettingsCubit] to be provided above it in the widget tree
/// (see `SettingsModule`).
/// {@endtemplate}
class SettingsPage extends StatelessWidget {
  /// {@macro settings_page}
  const SettingsPage({
    super.key,
    this.loadIndoorTemperatureSourceAvailability,
  });

  /// Loads source availability for the source-selection controls.
  final Future<Map<IndoorTemperaturePreference, bool>> Function()?
  loadIndoorTemperatureSourceAvailability;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsCubit>().state;
    final settings = state.settings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _buildBody(context, state, settings),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SettingsState state,
    UserSettings? settings,
  ) {
    final l10n = context.l10n;

    if (settings == null && state.status == SettingsStatus.error) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        children: [
          GlassPageHeader(title: l10n.settings),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
              ],
            ),
          ),
        ],
      );
    }

    if (settings == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        children: [
          GlassPageHeader(title: l10n.settings),
          const SizedBox(height: 80),
          const Center(
            child: CircularProgressIndicator(color: GlassTokens.onGlass),
          ),
        ],
      );
    }

    return _SettingsForm(
      initial: settings,
      isSaving: state.status == SettingsStatus.saving,
      errorMessage: state.status == SettingsStatus.error
          ? state.errorMessage
          : null,
      loadIndoorTemperatureSourceAvailability:
          loadIndoorTemperatureSourceAvailability,
      onSave: (updated) => context.read<SettingsCubit>().save(updated),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({
    required this.initial,
    required this.isSaving,
    required this.onSave,
    this.loadIndoorTemperatureSourceAvailability,
    this.errorMessage,
  });

  final UserSettings initial;
  final bool isSaving;
  final String? errorMessage;
  final Future<Map<IndoorTemperaturePreference, bool>> Function()?
  loadIndoorTemperatureSourceAvailability;
  final ValueChanged<UserSettings> onSave;

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  static const double _minOffsetCelsius = -10;
  static const double _maxOffsetCelsius = 10;
  static const double _offsetStepCelsius = 0.5;
  static const double _minThresholdCelsius = -20;
  static const double _maxThresholdCelsius = 50;

  late Units _units;
  late double _minCelsius;
  late double _maxCelsius;
  late bool _thresholdEnabled;
  late double _indoorOffsetCelsius;
  late IndoorTemperaturePreference _indoorTemperaturePreference;
  late double? _manualIndoorTemperatureCelsius;

  @override
  void initState() {
    super.initState();
    _units = widget.initial.units;
    _minCelsius = widget.initial.threshold.minCelsius;
    _maxCelsius = widget.initial.threshold.maxCelsius;
    _thresholdEnabled = widget.initial.threshold.enabled;
    _indoorOffsetCelsius = widget.initial.indoorOffsetCelsius;
    _indoorTemperaturePreference = widget.initial.indoorTemperaturePreference;
    _manualIndoorTemperatureCelsius =
        widget.initial.manualIndoorTemperatureCelsius;
  }

  String _formatCelsius(double celsius) {
    final displayed = _units.fromCelsius(celsius);
    return '${displayed.toStringAsFixed(1)}${_units.symbol}';
  }

  void _handleSave() {
    widget.onSave(
      UserSettings(
        units: _units,
        threshold: ThresholdSettings(
          minCelsius: _minCelsius,
          maxCelsius: _maxCelsius,
          enabled: _thresholdEnabled,
        ),
        indoorOffsetCelsius: _indoorOffsetCelsius,
        indoorTemperaturePreference: _indoorTemperaturePreference,
        manualIndoorTemperatureCelsius: _manualIndoorTemperatureCelsius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Theme(
      data: _glassControlsTheme(context),
      child: DefaultTextStyle(
        style: const TextStyle(color: GlassTokens.onGlass, height: 1.35),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            GlassPageHeader(title: l10n.settings),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.units),
                  const SizedBox(height: 14),
                  GlassSegmentedToggle(
                    labels: [l10n.celsius, l10n.fahrenheit],
                    selectedIndex: _units == Units.celsius ? 0 : 1,
                    onChanged: (index) => setState(
                      () => _units = index == 0
                          ? Units.celsius
                          : Units.fahrenheit,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.thresholds),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.enableAlerts,
                      style: const TextStyle(color: GlassTokens.onGlass),
                    ),
                    value: _thresholdEnabled,
                    onChanged: (value) =>
                        setState(() => _thresholdEnabled = value),
                  ),
                  Text(
                    '${l10n.minTemperature}: ${_formatCelsius(_minCelsius)}',
                    style: const TextStyle(color: GlassTokens.onGlassMuted),
                  ),
                  Text(
                    '${l10n.maxTemperature}: ${_formatCelsius(_maxCelsius)}',
                    style: const TextStyle(color: GlassTokens.onGlassMuted),
                  ),
                  RangeSlider(
                    min: _minThresholdCelsius,
                    max: _maxThresholdCelsius,
                    divisions: (_maxThresholdCelsius - _minThresholdCelsius)
                        .round(),
                    labels: RangeLabels(
                      _formatCelsius(_minCelsius),
                      _formatCelsius(_maxCelsius),
                    ),
                    values: RangeValues(_minCelsius, _maxCelsius),
                    onChanged: _thresholdEnabled
                        ? (values) => setState(() {
                            _minCelsius = values.start;
                            _maxCelsius = values.end;
                          })
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.indoorOffset),
                  const SizedBox(height: 6),
                  Text(
                    l10n.indoorOffsetHint,
                    style: const TextStyle(
                      color: GlassTokens.onGlassMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatCelsius(_indoorOffsetCelsius),
                    style: const TextStyle(
                      color: GlassTokens.onGlass,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Slider(
                    min: _minOffsetCelsius,
                    max: _maxOffsetCelsius,
                    divisions:
                        ((_maxOffsetCelsius - _minOffsetCelsius) /
                                _offsetStepCelsius)
                            .round(),
                    label: _formatCelsius(_indoorOffsetCelsius),
                    value: _indoorOffsetCelsius,
                    onChanged: (value) =>
                        setState(() => _indoorOffsetCelsius = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Indoor Temperature Source'),
                  const SizedBox(height: 6),
                  const Text(
                    'Automatic uses the first available source: Phone '
                    'Ambient Sensor, Bluetooth Sensor, Battery Temperature, '
                    'Manual, then Estimated.',
                    style: TextStyle(
                      color: GlassTokens.onGlassMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<Map<IndoorTemperaturePreference, bool>>(
                    future: widget.loadIndoorTemperatureSourceAvailability
                        ?.call(),
                    builder: (context, snapshot) {
                      final availability = snapshot.data ?? const {};
                      return Column(
                        children: [
                          for (final preference
                              in IndoorTemperaturePreference.values) ...[
                            GlassSelectTile(
                              title: _sourceLabel(preference),
                              subtitle: _sourceSubtitle(
                                preference,
                                availability,
                              ),
                              icon: _sourceIcon(preference),
                              selected:
                                  preference == _indoorTemperaturePreference,
                              enabled: !_isUnavailable(
                                preference,
                                availability,
                              ),
                              onTap: () {
                                setState(() {
                                  _indoorTemperaturePreference = preference;
                                  if (preference ==
                                          IndoorTemperaturePreference.manual &&
                                      _manualIndoorTemperatureCelsius == null) {
                                    _manualIndoorTemperatureCelsius = 22;
                                  }
                                });
                              },
                            ),
                            if (preference !=
                                IndoorTemperaturePreference.estimated)
                              const SizedBox(height: 8),
                          ],
                        ],
                      );
                    },
                  ),
                  if (_indoorTemperaturePreference ==
                      IndoorTemperaturePreference.batteryTemperature) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Battery temperature is the temperature of the phone '
                      'battery, not the actual room temperature. It can be '
                      'affected by charging, CPU usage, sunlight, and device '
                      'workload.',
                      style: TextStyle(
                        color: GlassTokens.onGlassMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (_indoorTemperaturePreference ==
                      IndoorTemperaturePreference.manual) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Manual: ${_formatCelsius(
                        _manualIndoorTemperatureCelsius ?? 22,
                      )}',
                      style: const TextStyle(color: GlassTokens.onGlass),
                    ),
                    Slider(
                      min: _minThresholdCelsius,
                      max: _maxThresholdCelsius,
                      divisions: (_maxThresholdCelsius - _minThresholdCelsius)
                          .round(),
                      label: _formatCelsius(
                        _manualIndoorTemperatureCelsius ?? 22,
                      ),
                      value: _manualIndoorTemperatureCelsius ?? 22,
                      onChanged: (value) => setState(
                        () => _manualIndoorTemperatureCelsius = value,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.errorMessage != null) ...[
              Text(
                widget.errorMessage!,
                style: const TextStyle(color: Color(0xFFFFB4A9)),
              ),
              const SizedBox(height: 16),
            ],
            Theme(
              data: Theme.of(context).copyWith(
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    backgroundColor: GlassTokens.tintSelected,
                    foregroundColor: GlassTokens.onSelected,
                    disabledBackgroundColor: const Color(0x66FFFFFF),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              child: PrimaryButton(
                label: l10n.save,
                isLoading: widget.isSaving,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData _glassControlsTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      sliderTheme: const SliderThemeData(
        activeTrackColor: GlassTokens.onGlass,
        inactiveTrackColor: Color(0x33FFFFFF),
        thumbColor: Colors.white,
        overlayColor: Color(0x33FFFFFF),
        valueIndicatorColor: Color(0xE6151B20),
        valueIndicatorTextStyle: TextStyle(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xCCFFFFFF);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0x99FFFFFF);
          }
          return const Color(0x40FFFFFF);
        }),
      ),
    );
  }

  bool _isUnavailable(
    IndoorTemperaturePreference preference,
    Map<IndoorTemperaturePreference, bool> availability,
  ) {
    if (preference == IndoorTemperaturePreference.automatic ||
        preference == IndoorTemperaturePreference.manual ||
        preference == IndoorTemperaturePreference.estimated) {
      return false;
    }
    return availability[preference] == false;
  }

  String? _sourceSubtitle(
    IndoorTemperaturePreference preference,
    Map<IndoorTemperaturePreference, bool> availability,
  ) {
    if (_isUnavailable(preference, availability)) {
      return 'Unavailable on this device';
    }
    return null;
  }

  IconData _sourceIcon(IndoorTemperaturePreference preference) {
    return switch (preference) {
      IndoorTemperaturePreference.automatic => Icons.auto_mode_outlined,
      IndoorTemperaturePreference.ambientSensor => Icons.sensors_outlined,
      IndoorTemperaturePreference.bluetoothSensor => Icons.bluetooth_outlined,
      IndoorTemperaturePreference.batteryTemperature =>
        Icons.battery_4_bar_outlined,
      IndoorTemperaturePreference.manual => Icons.edit_outlined,
      IndoorTemperaturePreference.estimated => Icons.auto_awesome_outlined,
    };
  }

  String _sourceLabel(IndoorTemperaturePreference preference) {
    return switch (preference) {
      IndoorTemperaturePreference.automatic => 'Automatic',
      IndoorTemperaturePreference.ambientSensor => 'Phone Ambient Sensor',
      IndoorTemperaturePreference.bluetoothSensor => 'Bluetooth Sensor',
      IndoorTemperaturePreference.batteryTemperature => 'Battery Temperature',
      IndoorTemperaturePreference.manual => 'Manual',
      IndoorTemperaturePreference.estimated => 'Estimated',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: GlassTokens.onGlass,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
      ),
    );
  }
}
