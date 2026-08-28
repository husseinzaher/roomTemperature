import 'package:flutter/foundation.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:local_database/local_database.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';
import 'package:room_temperature_app/home/home_widget_labels.dart';
import 'package:room_temperature_app/places/place_history_repository.dart';
import 'package:room_temperature_app/places/place_visit_tracker.dart';
import 'package:room_temperature_app/services/background_data_refresh.dart';
import 'package:room_temperature_app/services/indoor_temperature_bindings.dart';
import 'package:room_temperature_app/services/location_service.dart';
import 'package:settings_data/settings_data.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:workmanager/workmanager.dart';

/// Legacy WorkManager unique name (threshold-only). Cancelled on register.
const thresholdMonitorUniqueName = 'threshold-monitor';

/// Legacy WorkManager task name. Still accepted by the dispatcher.
const thresholdMonitorTaskName = 'thresholdMonitorTask';

/// WorkManager task name for the global data refresh.
const dataRefreshTaskName = 'dataRefreshTask';

/// WorkManager unique-work name for the global data refresh.
const dataRefreshUniqueName = 'data-refresh';

/// Initializes the WorkManager plugin. Call once from app bootstrap.
Future<void> initializeBackgroundRefresh() async {
  await Workmanager().initialize(notificationsCallbackDispatcher);
}

/// Registers periodic background refresh at [requested] (capped to Android's
/// 15-minute periodic minimum). Safe to call when the user changes the
/// interval — existing work is replaced.
///
/// Android does **not** guarantee exact 1-minute background execution.
Future<void> registerBackgroundDataRefresh(Duration requested) async {
  final frequency = RefreshInterval.backgroundFrequency(requested);
  try {
    await Workmanager().cancelByUniqueName(thresholdMonitorUniqueName);
    await Workmanager().cancelByUniqueName(dataRefreshUniqueName);
    await Workmanager().registerPeriodicTask(
      dataRefreshUniqueName,
      dataRefreshTaskName,
      frequency: frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  } on Exception catch (error, stackTrace) {
    debugPrint('registerBackgroundDataRefresh failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

/// The top-level WorkManager callback — runs in its own background isolate.
@pragma('vm:entry-point')
void notificationsCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != dataRefreshTaskName && task != thresholdMonitorTaskName) {
      return true;
    }

    final database = AppDatabase();
    try {
      await _runBackgroundRefresh(database);
    } on Exception catch (error, stackTrace) {
      debugPrint('background refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      await database.close();
    }
    return true;
  });
}

Future<void> _runBackgroundRefresh(AppDatabase database) async {
  final temperatureRepository = DriftTemperatureRepository(
    database: database,
  );
  final settingsRepository = DriftSettingsRepository(database: database);
  final openMeteo = OpenMeteoClient();
  final weatherRepository = OpenMeteoWeatherRepository(openMeteo);
  const locationService = LocationService();
  const homeWidget = HomeWidgetBridge();
  final weatherCache = WeatherCacheStore(database);
  final placeRepository = PlaceHistoryRepository(
    database: database,
    lookupName: (latitude, longitude) => openMeteo.lookupPlaceName(
      latitude: latitude,
      longitude: longitude,
    ),
  );
  final indoorService = buildIndoorTemperatureService(
    database: database,
    settingsRepository: settingsRepository,
  );

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

  final refresh = BackgroundDataRefresh(
    resolveIndoor: () async {
      final settings = await settingsRepository.watchSettings().first;
      return indoorService.resolve(
        preference: settings.indoorTemperaturePreference,
      );
    },
    fetchWeather: () async {
      try {
        final location = await locationService.getCurrentLocation();
        final weather = await weatherRepository.fetchOutsideWeather(
          location: location,
        );
        await weatherCache.save(weather);
        return weather;
      } on Exception {
        return weatherCache.load();
      }
    },
    readLatest: () => temperatureRepository.watchLatestReading().first,
    persist: (reading) =>
        temperatureRepository.recordReading(reading: reading),
    syncWidget: (reading, weather) async {
      final settings = await settingsRepository.watchSettings().first;
      await homeWidget.saveRefreshIntervalMinutes(
        RefreshInterval.clamp(settings.refreshInterval).inMinutes,
      );
      final tracker = PlaceVisitTracker(
        repository: placeRepository,
        locationService: locationService,
      );
      await tracker.observe(
        settings: settings,
        indoorCelsius:
            reading.roomTemperatureSource ==
                RoomTemperatureSource.batteryTemperature
            ? indoorService.lastEstimate?.temperatureCelsius
            : reading.roomTemperatureCelsius,
        at: reading.timestamp,
      );
      final places = await tracker.repository.listPlaces();
      await syncHomeWidget(
        bridge: homeWidget,
        reading: reading,
        settings: settings,
        weather: weather,
        recentPlace: places.isEmpty ? null : places.first,
        places: places,
      );
    },
    checkThresholds: monitor.check,
  );

  await refresh.run();
}

/// The last-known breach state, cached in `shared_preferences`.
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
