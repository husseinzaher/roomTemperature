import 'package:notifications_domain/notifications_domain.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template threshold_monitor}
/// Orchestrates a single threshold check for a user: fetches the latest
/// reading and settings, evaluates/notifies on breach-state changes via
/// [evaluateAndNotify], and persists the resulting breach state.
///
/// Every collaborator is injected as a function, so this class has zero
/// direct dependency on Firestore, `shared_preferences`, `workmanager`, or
/// Firebase-in-a-background-isolate concerns. That makes it callable both
/// from a foreground periodic `Timer` and from a top-level `workmanager`
/// callback (which must run in a background isolate and be registered from
/// the app's `main.dart`) — wiring either of those is an app-layer concern.
/// {@endtemplate}
class ThresholdMonitor {
  /// {@macro threshold_monitor}
  const ThresholdMonitor({
    required this.evaluateAndNotify,
    required this.getLatestReading,
    required this.getSettings,
    required this.getLastBreach,
    required this.setLastBreach,
  });

  /// The domain command that evaluates a reading against settings and
  /// sends a notification on breach-state change.
  final EvaluateAndNotifyCommand evaluateAndNotify;

  /// Fetches the latest [Reading] for the user identified by `userId`, or
  /// `null` if none exists yet.
  final Future<Reading?> Function(String userId) getLatestReading;

  /// Fetches the [ThresholdSettings] for the user identified by `userId`,
  /// or `null` if none have been configured yet.
  final Future<ThresholdSettings?> Function(String userId) getSettings;

  /// Fetches the persisted "last known breach" for the user identified by
  /// `userId`, so state-change detection survives process restarts.
  final Future<ThresholdBreach> Function(String userId) getLastBreach;

  /// Persists the "last known breach" for the user identified by `userId`.
  final Future<void> Function(String userId, ThresholdBreach breach)
  setLastBreach;

  /// Runs a single threshold check for the user identified by [userId].
  ///
  /// Does nothing if there is no reading or no settings yet for the user.
  Future<void> check(String userId) async {
    final reading = await getLatestReading(userId);
    final settings = await getSettings(userId);
    if (reading == null || settings == null) return;

    final previousBreach = await getLastBreach(userId);
    final newBreach = await evaluateAndNotify.execute(
      reading: reading,
      settings: settings,
      previousBreach: previousBreach,
    );
    await setLastBreach(userId, newBreach);
  }
}
