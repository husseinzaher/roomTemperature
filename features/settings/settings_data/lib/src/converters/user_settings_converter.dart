import 'package:settings_domain/settings_domain.dart';

/// {@template user_settings_converter}
/// Converts between the domain [UserSettings] model and the flat
/// `Map<String, String>` of key/value rows it is stored as.
///
/// Every field is persisted as its own row under the keys exposed below, so
/// adding a setting never needs a schema migration and a feature that owns
/// its own key can write it without going through [UserSettings] at all.
///
/// [fromMap] is deliberately tolerant of missing or malformed values: a
/// fresh install, a partially written store, or a value left behind by an
/// older build must never crash the app, so every unreadable field falls
/// back to the corresponding field of [UserSettings.defaults] on its own.
/// {@endtemplate}
class UserSettingsConverter {
  /// {@macro user_settings_converter}
  const UserSettingsConverter();

  /// The settings key for [UserSettings.units].
  static const String unitsKey = 'units';

  /// The settings key for [ThresholdSettings.minCelsius].
  static const String thresholdMinKey = 'thresholdMinC';

  /// The settings key for [ThresholdSettings.maxCelsius].
  static const String thresholdMaxKey = 'thresholdMaxC';

  /// The settings key for [ThresholdSettings.enabled].
  static const String thresholdEnabledKey = 'thresholdEnabled';

  /// The settings key for [UserSettings.indoorOffsetCelsius].
  static const String indoorOffsetKey = 'indoorOffsetC';

  /// The settings key for [UserSettings.indoorTemperaturePreference].
  static const String indoorTemperaturePreferenceKey =
      'indoorTemperatureSource';

  /// The settings key for [UserSettings.manualIndoorTemperatureCelsius].
  ///
  /// An empty value means "no manual temperature entered".
  static const String manualIndoorTemperatureKey = 'manualIndoorTempC';

  /// The settings key for [UserSettings.refreshInterval], stored as minutes.
  static const String refreshIntervalMinutesKey = 'refreshIntervalMinutes';

  /// The settings key for [UserSettings.placeHistoryEnabled].
  static const String placeHistoryEnabledKey = 'placeHistoryEnabled';

  /// Builds a [UserSettings] from the stored key/value [values].
  ///
  /// Any missing or malformed value falls back to the matching field of
  /// [UserSettings.defaults] instead of throwing.
  UserSettings fromMap(Map<String, String> values) {
    final defaults = UserSettings.defaults();

    return UserSettings(
      units: _enumOrDefault(
        values[unitsKey],
        Units.values,
        defaults.units,
      ),
      threshold: ThresholdSettings(
        minCelsius: _doubleOrDefault(
          values[thresholdMinKey],
          defaults.threshold.minCelsius,
        ),
        maxCelsius: _doubleOrDefault(
          values[thresholdMaxKey],
          defaults.threshold.maxCelsius,
        ),
        enabled: _boolOrDefault(
          values[thresholdEnabledKey],
          defaults.threshold.enabled,
        ),
      ),
      indoorOffsetCelsius: _doubleOrDefault(
        values[indoorOffsetKey],
        defaults.indoorOffsetCelsius,
      ),
      indoorTemperaturePreference: _enumOrDefault(
        values[indoorTemperaturePreferenceKey],
        IndoorTemperaturePreference.values,
        defaults.indoorTemperaturePreference,
      ),
      manualIndoorTemperatureCelsius:
          _nullableDouble(values[manualIndoorTemperatureKey]) ??
          defaults.manualIndoorTemperatureCelsius,
      refreshInterval: RefreshInterval.fromMinutes(
        _intOrNull(values[refreshIntervalMinutesKey]),
      ),
      placeHistoryEnabled: _boolOrDefault(
        values[placeHistoryEnabledKey],
        defaults.placeHistoryEnabled,
      ),
    );
  }

  /// Builds the exact set of key/value rows that represent [settings].
  Map<String, String> toMap(UserSettings settings) => {
    unitsKey: settings.units.name,
    thresholdMinKey: '${settings.threshold.minCelsius}',
    thresholdMaxKey: '${settings.threshold.maxCelsius}',
    thresholdEnabledKey: '${settings.threshold.enabled}',
    indoorOffsetKey: '${settings.indoorOffsetCelsius}',
    indoorTemperaturePreferenceKey: settings.indoorTemperaturePreference.name,
    manualIndoorTemperatureKey:
        settings.manualIndoorTemperatureCelsius?.toString() ?? '',
    refreshIntervalMinutesKey: '${settings.refreshInterval.inMinutes}',
    placeHistoryEnabledKey: '${settings.placeHistoryEnabled}',
  };

  T _enumOrDefault<T extends Enum>(
    String? value,
    List<T> allValues,
    T fallback,
  ) {
    if (value == null) return fallback;
    for (final candidate in allValues) {
      if (candidate.name == value) return candidate;
    }
    return fallback;
  }

  double _doubleOrDefault(String? value, double fallback) =>
      _nullableDouble(value) ?? fallback;

  bool _boolOrDefault(String? value, bool fallback) => switch (value) {
    'true' => true,
    'false' => false,
    _ => fallback,
  };

  double? _nullableDouble(String? value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value);
  }

  int? _intOrNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return int.tryParse(value) ?? double.tryParse(value)?.round();
  }
}
