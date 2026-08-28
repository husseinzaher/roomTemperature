import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:local_database/local_database.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:room_temperature_app/app/app.dart';
import 'package:room_temperature_app/services/notifications_background.dart';
import 'package:settings_data/settings_data.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  final notificationSender = FlutterLocalNotificationSender();
  await notificationSender.initialize();

  // The single on-device database every repository reads and writes.
  final database = AppDatabase();
  final settingsRepository = DriftSettingsRepository(database: database);

  await initializeBackgroundRefresh();
  final settings = await settingsRepository.watchSettings().first;
  await registerBackgroundDataRefresh(settings.refreshInterval);

  runApp(App(database: database, notificationSender: notificationSender));
}
