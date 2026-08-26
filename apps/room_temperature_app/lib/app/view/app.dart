import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:history_data/history_data.dart';
import 'package:history_domain/history_domain.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';
import 'package:provider/provider.dart';
import 'package:room_temperature_app/routing/router.dart';
import 'package:room_temperature_app/services/ambient_sensor_service.dart';
import 'package:room_temperature_app/services/battery_temperature_service.dart';
import 'package:room_temperature_app/services/indoor_temperature_service.dart';
import 'package:room_temperature_app/services/location_service.dart';
import 'package:settings_data/settings_data.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// The app root: constructs every repository this app needs and makes them
/// available (via [Provider]) to the feature modules below it.
class App extends StatelessWidget {
  /// Creates the [App] root widget.
  ///
  /// [sharedPreferences] and [notificationSender] are created up front in
  /// `bootstrap()` (the former needs an async factory, the latter needs
  /// its Android notification channel created before first use).
  const App({
    required this.sharedPreferences,
    required this.notificationSender,
    super.key,
  });

  /// A pre-initialized [SharedPreferences] instance, used to cache
  /// settings for instant offline reads.
  final SharedPreferences sharedPreferences;

  /// A pre-initialized local-notification sender.
  final FlutterLocalNotificationSender notificationSender;

  @override
  Widget build(BuildContext context) {
    final weatherRepository = OpenMeteoWeatherRepository(OpenMeteoClient());
    final temperatureRepository = LocalTemperatureRepository(
      sharedPreferences: sharedPreferences,
    );
    final historyRepository = LocalHistoryRepository(
      sharedPreferences: sharedPreferences,
    );
    final settingsRepository = LocalSettingsRepository(
      sharedPreferences: sharedPreferences,
    );
    const ambientSensorService = AmbientSensorService();
    const batteryTemperatureService = BatteryTemperatureService();
    final indoorTemperatureService = IndoorTemperatureService(
      ambientProvider: const AndroidAmbientTemperatureProvider(
        ambientSensorService,
      ),
      bluetoothProvider: const BluetoothTemperatureProvider(),
      batteryProvider: const BatteryTemperatureProvider(
        batteryTemperatureService,
      ),
      manualProvider: ManualTemperatureProvider(
        () => settingsRepository
            .lastSettingsOrDefault()
            .manualIndoorTemperatureCelsius,
      ),
    );

    return MultiProvider(
      providers: [
        Provider<ITemperatureRepository>.value(value: temperatureRepository),
        Provider<IWeatherRepository>.value(value: weatherRepository),
        Provider<IHistoryRepository>.value(value: historyRepository),
        Provider<ISettingsRepository>.value(value: settingsRepository),
        Provider<LocalSettingsRepository>.value(value: settingsRepository),
        Provider<INotificationSender>.value(value: notificationSender),
        Provider<HomeWidgetBridge>.value(value: const HomeWidgetBridge()),
        Provider<LocationService>.value(value: const LocationService()),
        Provider<AmbientSensorService>.value(
          value: ambientSensorService,
        ),
        Provider<BatteryTemperatureService>.value(
          value: batteryTemperatureService,
        ),
        Provider<IndoorTemperatureService>.value(
          value: indoorTemperatureService,
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: const HomeRoute().location,
      routes: $appRoutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
    );
  }
}
