// Placeholder Firebase configuration — NOT a real project.
//
// Replace this file by running, from apps/room_temperature_app:
//   flutterfire login
//   flutterfire configure
//
// That command generates a real version of this file wired to your own
// Firebase project (Auth + Firestore + Cloud Messaging) and is safe to
// commit — Firebase client config is not a secret, it only identifies
// which project the app talks to.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Firebase configuration for the current platform.
///
/// See the file header for how to replace this placeholder with your own
/// project's configuration.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have only been configured for Android in '
          'this project. Run `flutterfire configure` to add other '
          'platforms.',
        );
    }
  }

  /// Placeholder Android options — run `flutterfire configure` to replace.
  static const android = FirebaseOptions(
    apiKey: 'REPLACE_ME_run_flutterfire_configure',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-me-run-flutterfire-configure',
    storageBucket: 'replace-me-run-flutterfire-configure.appspot.com',
  );
}
