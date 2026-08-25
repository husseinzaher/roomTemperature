import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications_domain/notifications_domain.dart';

/// The Android notification channel id used for threshold alerts.
const String thresholdAlertsChannelId = 'threshold_alerts';

/// The Android notification channel name used for threshold alerts.
const String thresholdAlertsChannelName = 'Threshold Alerts';

/// {@template flutter_local_notification_sender}
/// An [INotificationSender] backed by `flutter_local_notifications`,
/// showing an OS-level notification for each [NotificationEvent].
/// {@endtemplate}
class FlutterLocalNotificationSender implements INotificationSender {
  /// {@macro flutter_local_notification_sender}
  FlutterLocalNotificationSender({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Sets up the Android notification channel used for threshold alerts
  /// and initializes the underlying plugin. Must be called once before
  /// [send] is used, typically during app startup.
  Future<void> initialize() async {
    const androidChannel = AndroidNotificationChannel(
      thresholdAlertsChannelId,
      thresholdAlertsChannelName,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _plugin.initialize(settings: initializationSettings);
  }

  @override
  Future<void> send(NotificationEvent event) async {
    const androidDetails = AndroidNotificationDetails(
      thresholdAlertsChannelId,
      thresholdAlertsChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: event.hashCode,
      title: event.title,
      body: event.body,
      notificationDetails: notificationDetails,
    );
  }
}
