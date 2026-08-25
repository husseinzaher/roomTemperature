import 'package:app_localization/src/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Convenience accessor for [AppLocalizations] on [BuildContext].
extension AppLocalizationsX on BuildContext {
  /// The [AppLocalizations] for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
