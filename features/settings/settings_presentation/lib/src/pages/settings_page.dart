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
    final l10n = context.l10n;
    final state = context.watch<SettingsCubit>().state;
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
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

    if (settings == null && state.status == SettingsStatus.loading) {
      return const LoadingView();
    }

    if (settings == null && state.status == SettingsStatus.error) {
      return ErrorRetryView(message: state.errorMessage ?? l10n.errorGeneric);
    }

    if (settings == null) {
      return const LoadingView();
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
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsetsDirectional.all(20),
      children: [
        Text(l10n.units, style: textTheme.titleMedium),
        const SizedBox(height: 12),
        SegmentedButton<Units>(
          segments: [
            ButtonSegment(value: Units.celsius, label: Text(l10n.celsius)),
            ButtonSegment(
              value: Units.fahrenheit,
              label: Text(l10n.fahrenheit),
            ),
          ],
          selected: {_units},
          onSelectionChanged: (selection) =>
              setState(() => _units = selection.first),
        ),
        const SizedBox(height: 32),
        Text(l10n.thresholds, style: textTheme.titleMedium),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.enableAlerts),
          value: _thresholdEnabled,
          onChanged: (value) => setState(() => _thresholdEnabled = value),
        ),
        const SizedBox(height: 8),
        Text('${l10n.minTemperature}: ${_formatCelsius(_minCelsius)}'),
        Text('${l10n.maxTemperature}: ${_formatCelsius(_maxCelsius)}'),
        const SizedBox(height: 8),
        RangeSlider(
          min: _minThresholdCelsius,
          max: _maxThresholdCelsius,
          divisions: (_maxThresholdCelsius - _minThresholdCelsius).round(),
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
        const SizedBox(height: 32),
        Text(l10n.indoorOffset, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.indoorOffsetHint,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(_formatCelsius(_indoorOffsetCelsius), style: textTheme.bodyLarge),
        Slider(
          min: _minOffsetCelsius,
          max: _maxOffsetCelsius,
          divisions:
              ((_maxOffsetCelsius - _minOffsetCelsius) / _offsetStepCelsius)
                  .round(),
          label: _formatCelsius(_indoorOffsetCelsius),
          value: _indoorOffsetCelsius,
          onChanged: (value) => setState(() => _indoorOffsetCelsius = value),
        ),
        const SizedBox(height: 32),
        Text('Indoor Temperature Source', style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Automatic uses the first available source: Phone Ambient Sensor, '
          'Bluetooth Sensor, Battery Temperature, Manual, then Estimated.',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<Map<IndoorTemperaturePreference, bool>>(
          future: widget.loadIndoorTemperatureSourceAvailability?.call(),
          builder: (context, snapshot) {
            final availability = snapshot.data ?? const {};
            return Column(
              children: [
                for (final preference in IndoorTemperaturePreference.values)
                  RadioListTile<IndoorTemperaturePreference>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_sourceLabel(preference)),
                    subtitle:
                        preference == IndoorTemperaturePreference.automatic
                        ? null
                        : (_isUnavailable(preference, availability)
                              ? const Text('Unavailable on this device')
                              : null),
                    value: preference,
                    // RadioListTile still owns selection until RadioGroup
                    // lands.
                    // ignore: deprecated_member_use
                    groupValue: _indoorTemperaturePreference,
                    // RadioListTile still owns selection until RadioGroup
                    // lands.
                    // ignore: deprecated_member_use
                    onChanged: _isUnavailable(preference, availability)
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _indoorTemperaturePreference = value;
                              if (value == IndoorTemperaturePreference.manual &&
                                  _manualIndoorTemperatureCelsius == null) {
                                _manualIndoorTemperatureCelsius = 22;
                              }
                            });
                          },
                  ),
              ],
            );
          },
        ),
        if (_indoorTemperaturePreference ==
            IndoorTemperaturePreference.batteryTemperature) ...[
          const SizedBox(height: 8),
          Text(
            'Battery temperature is the temperature of the phone battery, '
            'not the actual room temperature. It can be affected by charging, '
            'CPU usage, sunlight, and device workload.',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (_indoorTemperaturePreference ==
            IndoorTemperaturePreference.manual) ...[
          const SizedBox(height: 16),
          Text(
            'Manual: ${_formatCelsius(_manualIndoorTemperatureCelsius ?? 22)}',
          ),
          Slider(
            min: _minThresholdCelsius,
            max: _maxThresholdCelsius,
            divisions: (_maxThresholdCelsius - _minThresholdCelsius).round(),
            label: _formatCelsius(_manualIndoorTemperatureCelsius ?? 22),
            value: _manualIndoorTemperatureCelsius ?? 22,
            onChanged: (value) => setState(
              () => _manualIndoorTemperatureCelsius = value,
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (widget.errorMessage != null) ...[
          Text(
            widget.errorMessage!,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
        ],
        PrimaryButton(
          label: l10n.save,
          isLoading: widget.isSaving,
          onPressed: _handleSave,
        ),
      ],
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
