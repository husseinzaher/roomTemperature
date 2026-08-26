import 'package:mocktail/mocktail.dart';
import 'package:notifications_data/notifications_data.dart';
import 'package:notifications_domain/notifications_domain.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

class MockNotificationSender extends Mock implements INotificationSender {}

void main() {
  group('ThresholdMonitor', () {
    const userId = 'user-1';
    late INotificationSender sender;
    late EvaluateAndNotifyCommand evaluateAndNotify;

    Reading readingAt(double celsius) => Reading(
      roomTemperatureCelsius: celsius,
      roomTemperatureSource: RoomTemperatureSource.ambientSensor,
      outsideTemperatureCelsius: 15,
      timestamp: DateTime(2026),
    );

    const settings = ThresholdSettings(
      minCelsius: 18,
      maxCelsius: 28,
      enabled: true,
    );

    setUpAll(() {
      registerFallbackValue(
        NotificationEvent(
          title: 'fallback',
          body: 'fallback',
          kind: NotificationKind.thresholdBreached,
          triggeredAt: DateTime(2026),
        ),
      );
    });

    setUp(() {
      sender = MockNotificationSender();
      when(() => sender.send(any())).thenAnswer((_) async {});
      evaluateAndNotify = EvaluateAndNotifyCommand(
        evaluator: const ThresholdEvaluator(),
        sender: sender,
      );
    });

    test('does nothing when there is no reading yet', () async {
      var getLastBreachCalled = false;
      var setLastBreachCalled = false;

      final monitor = ThresholdMonitor(
        evaluateAndNotify: evaluateAndNotify,
        getLatestReading: (_) async => null,
        getSettings: (_) async => settings,
        getLastBreach: (_) async {
          getLastBreachCalled = true;
          return ThresholdBreach.none;
        },
        setLastBreach: (_, _) async {
          setLastBreachCalled = true;
        },
      );

      await monitor.check(userId);

      expect(getLastBreachCalled, isFalse);
      expect(setLastBreachCalled, isFalse);
      verifyNever(() => sender.send(any()));
    });

    test('does nothing when there are no settings yet', () async {
      var setLastBreachCalled = false;

      final monitor = ThresholdMonitor(
        evaluateAndNotify: evaluateAndNotify,
        getLatestReading: (_) async => readingAt(31),
        getSettings: (_) async => null,
        getLastBreach: (_) async => ThresholdBreach.none,
        setLastBreach: (_, _) async {
          setLastBreachCalled = true;
        },
      );

      await monitor.check(userId);

      expect(setLastBreachCalled, isFalse);
      verifyNever(() => sender.send(any()));
    });

    test(
      'evaluates a breach, notifies, and persists the new breach state',
      () async {
        String? persistedUserId;
        ThresholdBreach? persistedBreach;

        final monitor = ThresholdMonitor(
          evaluateAndNotify: evaluateAndNotify,
          getLatestReading: (_) async => readingAt(31.2),
          getSettings: (_) async => settings,
          getLastBreach: (_) async => ThresholdBreach.none,
          setLastBreach: (persistedForUserId, breach) async {
            persistedUserId = persistedForUserId;
            persistedBreach = breach;
          },
        );

        await monitor.check(userId);

        expect(persistedUserId, userId);
        expect(persistedBreach, ThresholdBreach.aboveMaximum);
        verify(() => sender.send(any())).called(1);
      },
    );

    test(
      'does not resend while already breached, but keeps persisting',
      () async {
        ThresholdBreach? persistedBreach;

        final monitor = ThresholdMonitor(
          evaluateAndNotify: evaluateAndNotify,
          getLatestReading: (_) async => readingAt(31.2),
          getSettings: (_) async => settings,
          getLastBreach: (_) async => ThresholdBreach.aboveMaximum,
          setLastBreach: (_, breach) async {
            persistedBreach = breach;
          },
        );

        await monitor.check(userId);

        expect(persistedBreach, ThresholdBreach.aboveMaximum);
        verifyNever(() => sender.send(any()));
      },
    );
  });
}
