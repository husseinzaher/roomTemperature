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
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaLeRiHCrn6xHRsKZp85iZcviSGi_gQXE',
    appId: '1:1040907079313:android:2c8b19cab33274c775f930',
    messagingSenderId: '1040907079313',
    projectId: 'comma-room-temperature',
    storageBucket: 'comma-room-temperature.firebasestorage.app',
  );
}
