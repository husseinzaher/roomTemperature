import 'package:settings_domain/settings_domain.dart';

/// {@template user_settings_converter}
/// Converts between the domain [UserSettings] model and the plain
/// `Map<String, dynamic>` shape stored on the `users/{userId}` Firestore
/// profile document (and mirrored in the local cache).
///
/// The map produced by [toMap] contains exactly the fields owned by the
/// settings feature — `units`, `thresholdMinC`, `thresholdMaxC`,
/// `thresholdEnabled`, `indoorOffsetC` — and nothing else, so that callers
/// can safely merge-write it without clobbering fields owned by other
/// features on the same document (e.g. notifications' `fcmToken`).
///
/// [fromMap] is deliberately tolerant of missing or malformed fields: a
/// fresh or partial profile document must never crash the app, so any
/// absent or unreadable field falls back to the corresponding field of
/// [UserSettings.defaults].
/// {@endtemplate}
class UserSettingsConverter {
  /// {@macro user_settings_converter}
  const UserSettingsConverter();

  /// The Firestore/cache field name for [UserSettings.units].
  static const String unitsField = 'units';

  /// The Firestore/cache field name for
  /// [ThresholdSettings.minCelsius].
  static const String thresholdMinField = 'thresholdMinC';

  /// The Firestore/cache field name for
  /// [ThresholdSettings.maxCelsius].
  static const String thresholdMaxField = 'thresholdMaxC';

  /// The Firestore/cache field name for [ThresholdSettings.enabled].
  static const String thresholdEnabledField = 'thresholdEnabled';

  /// The Firestore/cache field name for [UserSettings.indoorOffsetCelsius].
  static const String indoorOffsetField = 'indoorOffsetC';

  /// Builds a [UserSettings] from a raw Firestore/cache [data] map.
  ///
  /// Any missing or malformed field falls back to the matching field of
  /// [UserSettings.defaults] instead of throwing.
  UserSettings fromMap(Map<String, dynamic> data) {
    final defaults = UserSettings.defaults();

    return UserSettings(
      units: _unitsOrDefault(data[unitsField], defaults.units),
      threshold: ThresholdSettings(
        minCelsius: _doubleOrDefault(
          data[thresholdMinField],
          defaults.threshold.minCelsius,
        ),
        maxCelsius: _doubleOrDefault(
          data[thresholdMaxField],
          defaults.threshold.maxCelsius,
        ),
        enabled: _boolOrDefault(
          data[thresholdEnabledField],
          defaults.threshold.enabled,
        ),
      ),
      indoorOffsetCelsius: _doubleOrDefault(
        data[indoorOffsetField],
        defaults.indoorOffsetCelsius,
      ),
    );
  }

  /// Builds the exact Firestore/cache map for [settings]: only the five
  /// fields this feature owns, no more, no less.
  Map<String, dynamic> toMap(UserSettings settings) => {
    unitsField: settings.units.name,
    thresholdMinField: settings.threshold.minCelsius,
    thresholdMaxField: settings.threshold.maxCelsius,
    thresholdEnabledField: settings.threshold.enabled,
    indoorOffsetField: settings.indoorOffsetCelsius,
  };

  Units _unitsOrDefault(Object? value, Units fallback) {
    if (value is! String) return fallback;
    for (final unit in Units.values) {
      if (unit.name == value) return unit;
    }
    return fallback;
  }

  double _doubleOrDefault(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  bool _boolOrDefault(Object? value, bool fallback) {
    if (value is bool) return value;
    return fallback;
  }
}
