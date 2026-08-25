import 'dart:async';

import 'package:app_localization/app_localization.dart';
import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:history_data/history_data.dart';
import 'package:history_domain/history_domain.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';
import 'package:provider/provider.dart';
import 'package:room_temperature_app/routing/go_router_refresh_stream.dart';
import 'package:room_temperature_app/routing/router.dart';
import 'package:room_temperature_app/services/ambient_sensor_service.dart';
import 'package:room_temperature_app/services/current_user_cache.dart';
import 'package:room_temperature_app/services/fcm_token_sync.dart';
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
    final authRepository = FirebaseAuthRepository();
    final weatherRepository = OpenMeteoWeatherRepository(OpenMeteoClient());
    final temperatureRepository = FirestoreTemperatureRepository();
    final historyRepository = FirestoreHistoryRepository();
    final settingsRepository = FirestoreSettingsRepository(
      localCache: sharedPreferences,
    );
    final notificationTokenRepository = FirestoreNotificationTokenRepository();

    return MultiProvider(
      providers: [
        Provider<ITemperatureRepository>.value(value: temperatureRepository),
        Provider<IWeatherRepository>.value(value: weatherRepository),
        Provider<IHistoryRepository>.value(value: historyRepository),
        Provider<ISettingsRepository>.value(value: settingsRepository),
        Provider<INotificationSender>.value(value: notificationSender),
        Provider<INotificationTokenRepository>.value(
          value: notificationTokenRepository,
        ),
        Provider<HomeWidgetBridge>.value(value: const HomeWidgetBridge()),
        Provider<LocationService>.value(value: const LocationService()),
        Provider<AmbientSensorService>.value(
          value: const AmbientSensorService(),
        ),
      ],
      child: AuthModule(
        authRepository: authRepository,
        child: const _AppView(),
      ),
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
  late final AuthStatusCubit _authStatusCubit;
  late final FcmTokenSync _fcmTokenSync;
  StreamSubscription<AuthUser?>? _authSubscription;
  bool _authStateKnown = false;

  static const _loggingInPaths = {'/login', '/signup', '/forgot-password'};

  @override
  void initState() {
    super.initState();
    _authStatusCubit = context.read<AuthStatusCubit>();
    _fcmTokenSync = FcmTokenSync(
      tokenRepository: context.read<INotificationTokenRepository>(),
    );

    _router = GoRouter(
      initialLocation: const SplashRoute().location,
      refreshListenable: GoRouterRefreshStream(_authStatusCubit.stream),
      redirect: (context, state) => _redirect(state),
      routes: $appRoutes,
    );

    _authSubscription = _authStatusCubit.stream.listen((user) {
      _authStateKnown = true;
      unawaited(_handleAuthChange(user));
    });
  }

  Future<void> _handleAuthChange(AuthUser? user) async {
    await const CurrentUserCache().save(user?.uid);
    if (user != null) {
      await _fcmTokenSync.start(user.uid);
    } else {
      await _fcmTokenSync.stop();
    }
  }

  String? _redirect(GoRouterState state) {
    if (!_authStateKnown) {
      return state.matchedLocation == const SplashRoute().location
          ? null
          : const SplashRoute().location;
    }

    final isSignedIn = _authStatusCubit.state != null;
    final atLoggingInPath = _loggingInPaths.contains(state.matchedLocation);

    if (!isSignedIn) {
      return atLoggingInPath ? null : const LoginRoute().location;
    }

    if (atLoggingInPath ||
        state.matchedLocation == const SplashRoute().location) {
      return const HomeRoute().location;
    }

    return null;
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_fcmTokenSync.stop());
    super.dispose();
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
