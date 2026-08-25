import 'package:flutter/widgets.dart';
import 'package:room_temperature_app/l10n/gen/app_localizations.dart';

export 'package:room_temperature_app/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
