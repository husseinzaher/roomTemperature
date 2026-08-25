import 'package:app_localization/app_localization.dart';
import 'package:flutter/widgets.dart';

/// Maps a domain/data-layer error code (from `AuthException.code`, or a
/// local validation code such as `'password-mismatch'`) to a localized,
/// user-facing message.
String authErrorText(BuildContext context, String? errorCode) {
  final l10n = context.l10n;
  switch (errorCode) {
    case 'invalid-credentials':
      return l10n.errorInvalidCredentials;
    case 'weak-password':
      return l10n.errorWeakPassword;
    case 'email-in-use':
      return l10n.errorEmailInUse;
    case 'network-error':
      return l10n.errorNetwork;
    case 'password-mismatch':
      // No dedicated l10n key exists for this local-validation case; a
      // later integration pass may want to add one.
      return 'Passwords do not match.';
    default:
      return l10n.errorGeneric;
  }
}
