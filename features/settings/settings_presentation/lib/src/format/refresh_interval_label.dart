import 'package:app_localization/app_localization.dart';
import 'package:settings_domain/settings_domain.dart';

/// Localized label for a [RefreshInterval] duration, e.g. `15 minutes`.
String refreshIntervalLabel(Duration interval, AppLocalizations l10n) {
  final clamped = RefreshInterval.clamp(interval);
  if (clamped.inHours >= 1 && clamped.inMinutes % 60 == 0) {
    final hours = clamped.inHours;
    if (hours == 1) {
      return l10n.refreshIntervalOneHour;
    }
    return l10n.refreshIntervalHours(hours);
  }
  final minutes = clamped.inMinutes;
  if (minutes == 1) {
    return l10n.refreshIntervalOneMinute;
  }
  return l10n.refreshIntervalMinutes(minutes);
}
