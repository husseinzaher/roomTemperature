import 'package:local_database/local_database.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';
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
/// so it opens its own connection to the on-device database rather than
/// relying on any app-level singleton.
@pragma('vm:entry-point')
void notificationsCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != thresholdMonitorTaskName) return true;

    final database = AppDatabase();
    final temperatureRepository = DriftTemperatureRepository(
      database: database,
    );
    final settingsRepository = DriftSettingsRepository(database: database);
    const breachCache = _BreachCache();

    final sender = FlutterLocalNotificationSender();
    await sender.initialize();

    final monitor = ThresholdMonitor(
      evaluateAndNotify: EvaluateAndNotifyCommand(
        evaluator: const ThresholdEvaluator(),
        sender: sender,
      ),
      getLatestReading: () => temperatureRepository.watchLatestReading().first,
      getSettings: () async {
        final settings = await settingsRepository.watchSettings().first;
        return settings.threshold;
      },
      getLastBreach: breachCache.read,
      setLastBreach: breachCache.write,
    );

    await monitor.check();
    // Closing the isolate's own connection keeps the SQLite file unlocked
    // for the foreground app once this task finishes.
    await database.close();
    return true;
  });
}

/// The last-known breach state, cached in `shared_preferences` rather than
/// the database: it is derived scheduling state for this background task,
/// not user data, and reading it must not depend on the database being
/// open.
class _BreachCache {
  const _BreachCache();

  static const String _key = 'last_breach';

  Future<ThresholdBreach> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return ThresholdBreach.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => ThresholdBreach.none,
    );
  }

  Future<void> write(ThresholdBreach breach) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, breach.name);
  }
}
