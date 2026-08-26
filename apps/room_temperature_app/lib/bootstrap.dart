import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:room_temperature_app/app/app.dart';
import 'package:room_temperature_app/firebase_options.dart';
import 'package:room_temperature_app/services/notifications_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationSender = FlutterLocalNotificationSender();
  await notificationSender.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();

  await registerThresholdMonitor();

  runApp(
    App(
      sharedPreferences: sharedPreferences,
      notificationSender: notificationSender,
    ),
  );
}
