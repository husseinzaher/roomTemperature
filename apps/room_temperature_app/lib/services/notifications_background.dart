import 'package:firebase_core/firebase_core.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';
import 'package:room_temperature_app/firebase_options.dart';
import 'package:room_temperature_app/services/current_user_cache.dart';
import 'package:settings_data/settings_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:workmanager/workmanager.dart';

/// The WorkManager task name for the periodic threshold check.
const thresholdMonitorTaskName = 'thresholdMonitorTask';

/// The WorkManager unique-work name for the periodic threshold check.
const thresholdMonitorUniqueName = 'threshold-monitor';

/// Registers the periodic background threshold check. Safe to call every
/// app start — WorkManager de-duplicates by [thresholdMonitorUniqueName].
///
/// Android's WorkManager enforces a 15-minute minimum interval for
/// periodic tasks, so alerts fire on a best-effort ~15 minute cadence
/// while the app is backgrounded, not instantly.
Future<void> registerThresholdMonitor() async {
  await Workmanager().initialize(notificationsCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    thresholdMonitorUniqueName,
    thresholdMonitorTaskName,
    frequency: const Duration(minutes: 15),
  );
}

/// The top-level WorkManager callback — runs in its own background isolate,
/// so it re-initializes Firebase and constructs everything it needs from
/// scratch rather than relying on any app-level singleton.
@pragma('vm:entry-point')
void notificationsCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != thresholdMonitorTaskName) return true;

    final userId = await const CurrentUserCache().read();
    if (userId == null) return true;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final sender = FlutterLocalNotificationSender();
    await sender.initialize();

    final temperatureRepository = FirestoreTemperatureRepository();
    final settingsRepository = FirestoreSettingsRepository();
    final breachCache = _BreachCache();

    final monitor = ThresholdMonitor(
      evaluateAndNotify: EvaluateAndNotifyCommand(
        evaluator: const ThresholdEvaluator(),
        sender: sender,
      ),
      getLatestReading: (uid) =>
          temperatureRepository.watchLatestReading(userId: uid).first,
      getSettings: (uid) async {
        final settings = await settingsRepository
            .watchSettings(userId: uid)
            .first;
        return settings.threshold;
      },
      getLastBreach: breachCache.read,
      setLastBreach: breachCache.write,
    );

    await monitor.check(userId);
    return true;
  });
}

class _BreachCache {
  Future<ThresholdBreach> read(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('last_breach_$userId');
    return ThresholdBreach.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => ThresholdBreach.none,
    );
  }

  Future<void> write(String userId, ThresholdBreach breach) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_breach_$userId', breach.name);
  }
}
