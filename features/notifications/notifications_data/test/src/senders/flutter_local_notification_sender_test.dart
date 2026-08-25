import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';
import 'package:test/test.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

void main() {
  group('FlutterLocalNotificationSender', () {
    late MockFlutterLocalNotificationsPlugin plugin;
    late FlutterLocalNotificationSender sender;

    setUpAll(() {
      registerFallbackValue(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      registerFallbackValue(
        const AndroidNotificationChannel(
          thresholdAlertsChannelId,
          thresholdAlertsChannelName,
        ),
      );
      registerFallbackValue(
        const NotificationDetails(
          android: AndroidNotificationDetails(
            thresholdAlertsChannelId,
            thresholdAlertsChannelName,
          ),
        ),
      );
    });

    setUp(() {
      plugin = MockFlutterLocalNotificationsPlugin();
      sender = FlutterLocalNotificationSender(plugin: plugin);
    });

    test(
      'initialize creates the Android channel and initializes the plugin',
      () async {
        final androidImpl = MockAndroidFlutterLocalNotificationsPlugin();
        when(
          () => plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(androidImpl);
        when(
          () => androidImpl.createNotificationChannel(any()),
        ).thenAnswer((_) async {});
        when(
          () => plugin.initialize(settings: any(named: 'settings')),
        ).thenAnswer((_) async => true);

        await sender.initialize();

        final capturedChannel =
            verify(
                  () => androidImpl.createNotificationChannel(captureAny()),
                ).captured.single
                as AndroidNotificationChannel;
        expect(capturedChannel.id, thresholdAlertsChannelId);
        expect(capturedChannel.name, thresholdAlertsChannelName);
        expect(capturedChannel.importance, Importance.high);

        verify(
          () => plugin.initialize(settings: any(named: 'settings')),
        ).called(1);
      },
    );

    test('initialize tolerates a null Android implementation', () async {
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);
      when(
        () => plugin.initialize(settings: any(named: 'settings')),
      ).thenAnswer((_) async => true);

      await sender.initialize();

      verify(
        () => plugin.initialize(settings: any(named: 'settings')),
      ).called(1);
    });

    test('send shows a notification built from the event', () async {
      when(
        () => plugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
        ),
      ).thenAnswer((_) async {});

      final event = NotificationEvent(
        title: 'Room temperature alert',
        body: 'Room is now 31.2°C, above your 28.0°C limit.',
        kind: NotificationKind.thresholdBreached,
        triggeredAt: DateTime(2026),
      );

      await sender.send(event);

      final captured = verify(
        () => plugin.show(
          id: captureAny(named: 'id'),
          title: captureAny(named: 'title'),
          body: captureAny(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
        ),
      ).captured;

      expect(captured[0], event.hashCode);
      expect(captured[1], event.title);
      expect(captured[2], event.body);
      final details = captured[3] as NotificationDetails;
      expect(details.android?.importance, Importance.high);
      expect(details.android?.priority, Priority.high);
    });
  });
}
