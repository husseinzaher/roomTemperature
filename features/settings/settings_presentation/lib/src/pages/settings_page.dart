import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:settings_presentation/src/cubit/settings_cubit.dart';
import 'package:settings_presentation/src/cubit/settings_state.dart';
import 'package:settings_presentation/src/format/refresh_interval_label.dart';
import 'package:settings_presentation/src/pages/indoor_calibration.dart';
import 'package:settings_presentation/src/pages/place_history_host.dart';
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
    this.indoorCalibration,
    this.placeHistory,
  });

  /// Loads source availability for the source-selection controls.
  final Future<Map<IndoorTemperaturePreference, bool>> Function()?
  loadIndoorTemperatureSourceAvailability;

  /// Optional local indoor-temperature calibration, injected by the app.
  final IndoorCalibrationHost? indoorCalibration;

  /// Optional local place-history controls, injected by the app.
  final PlaceHistoryHost? placeHistory;

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
      indoorCalibration: indoorCalibration,
      placeHistory: placeHistory,
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
    this.indoorCalibration,
    this.placeHistory,
    this.errorMessage,
  });

  final UserSettings initial;
  final bool isSaving;
  final String? errorMessage;
  final Future<Map<IndoorTemperaturePreference, bool>> Function()?
  loadIndoorTemperatureSourceAvailability;
  final IndoorCalibrationHost? indoorCalibration;
  final PlaceHistoryHost? placeHistory;
  final ValueChanged<UserSettings> onSave;

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  static const double _minThresholdCelsius = -20;
  static const double _maxThresholdCelsius = 50;

  late Units _units;
  late double _minCelsius;
  late double _maxCelsius;
  late bool _thresholdEnabled;
  late double _indoorOffsetCelsius;
  late IndoorTemperaturePreference _indoorTemperaturePreference;
  late double? _manualIndoorTemperatureCelsius;
  late Duration _refreshInterval;
  late bool _placeHistoryEnabled;

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
    _refreshInterval = RefreshInterval.clamp(widget.initial.refreshInterval);
    _placeHistoryEnabled = widget.initial.placeHistoryEnabled;
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
        refreshInterval: _refreshInterval,
        placeHistoryEnabled: _placeHistoryEnabled,
      ),
    );
  }

  Future<void> _pickRefreshInterval(BuildContext context) async {
    final l10n = context.l10n;
    final selected = await showDialog<Duration>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectRefreshInterval,
                    style: const TextStyle(
                      color: GlassTokens.onGlass,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: RefreshInterval.available.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final interval = RefreshInterval.available[index];
                        return GlassSelectTile(
                          title: refreshIntervalLabel(interval, l10n),
                          selected: interval == _refreshInterval,
                          onTap: () => Navigator.of(dialogContext).pop(
                            interval,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected == null || !context.mounted) {
      return;
    }
    await _applyRefreshInterval(selected);
  }

  Future<void> _applyRefreshInterval(Duration interval) async {
    final clamped = RefreshInterval.clamp(interval);
    setState(() => _refreshInterval = clamped);
    final current =
        context.read<SettingsCubit>().state.settings ?? widget.initial;
    await context.read<SettingsCubit>().save(
      current.copyWith(refreshInterval: clamped),
    );
  }

  Future<void> _confirmDeletePlaceHistory(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deletePlaceHistory,
                  style: const TextStyle(
                    color: GlassTokens.onGlass,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.deletePlaceHistoryConfirm,
                  style: const TextStyle(
                    color: GlassTokens.onGlassMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(l10n.deletePlaceHistory),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await widget.placeHistory?.onDeleteAll();
    }
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
              key: const Key('refresh-interval-tile'),
              onTap: () => unawaited(_pickRefreshInterval(context)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(l10n.refreshInterval),
                        const SizedBox(height: 8),
                        Text(
                          refreshIntervalLabel(_refreshInterval, l10n),
                          style: const TextStyle(
                            color: GlassTokens.onGlassMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: GlassTokens.onGlassMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (widget.placeHistory != null) ...[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(l10n.placeHistory),
                    SwitchListTile(
                      key: const Key('place-history-switch'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.enablePlaceHistory,
                        style: const TextStyle(color: GlassTokens.onGlass),
                      ),
                      subtitle: Text(
                        l10n.placeHistoryHint,
                        style: const TextStyle(
                          color: GlassTokens.onGlassMuted,
                          fontSize: 13,
                        ),
                      ),
                      value: _placeHistoryEnabled,
                      onChanged: (value) {
                        setState(() => _placeHistoryEnabled = value);
                        unawaited(
                          widget.placeHistory!.onEnabledChanged(
                            enabled: value,
                          ),
                        );
                      },
                    ),
                    GlassSelectTile(
                      title: l10n.viewPlaces,
                      icon: Icons.place_outlined,
                      selected: false,
                      onTap: widget.placeHistory!.onOpenPlaces,
                    ),
                    const SizedBox(height: 8),
                    GlassSelectTile(
                      title: l10n.deletePlaceHistory,
                      icon: Icons.delete_outline,
                      selected: false,
                      onTap: () => unawaited(
                        _confirmDeletePlaceHistory(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
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
            if (widget.indoorCalibration != null)
              _IndoorCalibrationCard(host: widget.indoorCalibration!),
            if (widget.indoorCalibration != null) const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Indoor Temperature Source'),
                  const SizedBox(height: 6),
                  const Text(
                    'Automatic uses the first available local source: Phone '
                    'Ambient Sensor, Bluetooth Sensor, then the offline '
                    'thermal estimate, then Manual. Battery temperature is '
                    'never used automatically as room temperature.',
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
      IndoorTemperaturePreference.estimated => 'Local estimate',
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

class _IndoorCalibrationCard extends StatefulWidget {
  const _IndoorCalibrationCard({required this.host});

  final IndoorCalibrationHost host;

  @override
  State<_IndoorCalibrationCard> createState() => _IndoorCalibrationCardState();
}

class _IndoorCalibrationCardState extends State<_IndoorCalibrationCard> {
  final _referenceController = TextEditingController();
  IndoorCalibrationView _view = const IndoorCalibrationView();
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final view = await widget.host.load();
    if (!mounted) {
      return;
    }
    setState(() => _view = view);
  }

  Future<void> _calibrate() async {
    final actual = double.tryParse(_referenceController.text.trim());
    if (actual == null) {
      return;
    }
    setState(() => _busy = true);
    final result = await widget.host.calibrate(actual);
    if (!mounted) {
      return;
    }
    final l10n = context.l10n;
    setState(() {
      _busy = false;
      _message = result.poorConditions
          ? l10n.indoorCalibrationWarning
          : l10n.indoorCalibrationSaved;
    });
    await _reload();
  }

  Future<void> _reset() async {
    setState(() => _busy = true);
    await widget.host.reset();
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _message = null;
    });
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final estimate = _view.estimateCelsius;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(l10n.indoorCalibration),
          const SizedBox(height: 6),
          Text(
            l10n.indoorCalibrationHint,
            style: const TextStyle(
              color: GlassTokens.onGlassMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.indoorCurrentEstimate}: '
            '${estimate == null ? '—' : '${estimate.toStringAsFixed(1)}°C'}',
            style: const TextStyle(color: GlassTokens.onGlass, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            _view.statusLabel,
            style: const TextStyle(
              color: GlassTokens.onGlassMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.indoorReferenceTemperature,
            style: const TextStyle(color: GlassTokens.onGlass),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _referenceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            style: const TextStyle(color: GlassTokens.onGlass),
            decoration: const InputDecoration(
              suffixText: '°C',
              suffixStyle: TextStyle(color: GlassTokens.onGlassMuted),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0x66FFFFFF)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: l10n.indoorCalibrate,
                  isLoading: _busy,
                  onPressed: _calibrate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GlassTokens.onGlass,
                    side: const BorderSide(color: Color(0x66FFFFFF)),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.indoorResetCalibration),
                ),
              ),
            ],
          ),
          if (_message != null) ...[
            const SizedBox(height: 10),
            Text(
              _message!,
              style: const TextStyle(
                color: GlassTokens.onGlassMuted,
                fontSize: 13,
              ),
            ),
          ],
          if (_view.debugText != null) ...[
            const SizedBox(height: 16),
            const _SectionLabel('Indoor Temperature Debug'),
            const SizedBox(height: 8),
            SelectableText(
              _view.debugText!,
              style: const TextStyle(
                color: GlassTokens.onGlassMuted,
                fontSize: 12,
                height: 1.35,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
