/// Single source of truth for the global data-refresh interval.
///
/// User-facing refresh (app, background work, home widget) reads this
/// type. Indoor thermal *sampling* for `dT_batt/dt` may run more often
/// in the foreground — see [internalSampleInterval].
class RefreshInterval {
  /// Not constructed; use the static helpers.
  const RefreshInterval._();

  /// Fresh-install / fallback interval.
  static const Duration defaultInterval = Duration(minutes: 15);

  /// Shortest interval the user may select.
  static const Duration minimum = Duration(minutes: 1);

  /// Longest interval the user may select.
  static const Duration maximum = Duration(hours: 24);

  /// Android WorkManager minimum for periodic tasks.
  static const Duration androidBackgroundMinimum = Duration(minutes: 15);

  /// Selectable intervals shown in Settings.
  static const List<Duration> available = [
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 4),
    Duration(hours: 6),
    Duration(hours: 12),
    Duration(hours: 24),
  ];

  /// Returns [value] if it is in [[minimum], [maximum]], otherwise
  /// [defaultInterval]. Never throws.
  static Duration clamp(Duration? value) {
    if (value == null) {
      return defaultInterval;
    }
    if (value < minimum || value > maximum) {
      return defaultInterval;
    }
    return value;
  }

  /// Parses a stored minute count. Invalid values become [defaultInterval].
  static Duration fromMinutes(int? minutes) {
    if (minutes == null) {
      return defaultInterval;
    }
    return clamp(Duration(minutes: minutes));
  }

  /// WorkManager / background cadence for [requested].
  ///
  /// Intervals shorter than [androidBackgroundMinimum] are raised to that
  /// floor. Foreground timers still use the user's exact selection.
  static Duration backgroundFrequency(Duration requested) {
    final clamped = clamp(requested);
    if (clamped < androidBackgroundMinimum) {
      return androidBackgroundMinimum;
    }
    return clamped;
  }

  /// Foreground-only indoor thermal sampling cadence.
  ///
  /// When the user-facing interval is long, the estimator still needs
  /// periodic local snapshots for `dT_batt/dt`. This is not a second
  /// user setting.
  static Duration internalSampleInterval(Duration userFacing) {
    const sample = Duration(minutes: 2);
    final clamped = clamp(userFacing);
    if (clamped <= sample) {
      return clamped;
    }
    return sample;
  }

  /// English debug/label form, e.g. `15 minutes` or `1 hour`.
  static String debugLabel(Duration value) {
    final clamped = clamp(value);
    if (clamped.inHours >= 1 && clamped.inMinutes % 60 == 0) {
      final hours = clamped.inHours;
      return hours == 1 ? '1 hour' : '$hours hours';
    }
    final minutes = clamped.inMinutes;
    return minutes == 1 ? '1 minute' : '$minutes minutes';
  }
}
