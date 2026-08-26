import 'package:mocktail/mocktail.dart';
import 'package:notifications_domain/notifications_domain.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

class MockNotificationSender extends Mock implements INotificationSender {}

void main() {
  group('EvaluateAndNotifyCommand', () {
    late INotificationSender sender;
    late EvaluateAndNotifyCommand command;

    const settings = ThresholdSettings(
      minCelsius: 18,
      maxCelsius: 28,
      enabled: true,
    );

    Reading readingAt(double celsius) => Reading(
      roomTemperatureCelsius: celsius,
      roomTemperatureSource: RoomTemperatureSource.ambientSensor,
      outsideTemperatureCelsius: 15,
      timestamp: DateTime(2026),
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
      command = EvaluateAndNotifyCommand(
        evaluator: const ThresholdEvaluator(),
        sender: sender,
      );
      when(() => sender.send(any())).thenAnswer((_) async {});
    });

    test('sends a breach notification on none-to-breach transition', () async {
      final breach = await command.execute(
        reading: readingAt(31.2),
        settings: settings,
        previousBreach: ThresholdBreach.none,
      );

      expect(breach, ThresholdBreach.aboveMaximum);
      final captured = verify(() => sender.send(captureAny())).captured;
      expect(captured, hasLength(1));
      final event = captured.single as NotificationEvent;
      expect(event.kind, NotificationKind.thresholdBreached);
      expect(event.body, contains('31.2'));
      expect(event.body, contains('28.0'));
    });

    test(
      'does not resend when the breach kind is unchanged',
      () async {
        final breach = await command.execute(
          reading: readingAt(31.2),
          settings: settings,
          previousBreach: ThresholdBreach.aboveMaximum,
        );

        expect(breach, ThresholdBreach.aboveMaximum);
        verifyNever(() => sender.send(any()));
      },
    );

    test(
      'sends a restored notification on breach-to-none transition',
      () async {
        final breach = await command.execute(
          reading: readingAt(23),
          settings: settings,
          previousBreach: ThresholdBreach.aboveMaximum,
        );

        expect(breach, ThresholdBreach.none);
        final captured = verify(() => sender.send(captureAny())).captured;
        expect(captured, hasLength(1));
        final event = captured.single as NotificationEvent;
        expect(event.kind, NotificationKind.thresholdRestored);
        expect(event.body, contains('23.0'));
      },
    );

    test('sends nothing on none-to-none', () async {
      final breach = await command.execute(
        reading: readingAt(23),
        settings: settings,
        previousBreach: ThresholdBreach.none,
      );

      expect(breach, ThresholdBreach.none);
      verifyNever(() => sender.send(any()));
    });

    test(
      'sends a new breach notification when the breach direction changes',
      () async {
        final breach = await command.execute(
          reading: readingAt(10),
          settings: settings,
          previousBreach: ThresholdBreach.aboveMaximum,
        );

        expect(breach, ThresholdBreach.belowMinimum);
        final captured = verify(() => sender.send(captureAny())).captured;
        expect(captured, hasLength(1));
        final event = captured.single as NotificationEvent;
        expect(event.kind, NotificationKind.thresholdBreached);
      },
    );
  });
}
