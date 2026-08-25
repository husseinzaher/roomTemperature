import 'package:notifications_domain/src/evaluator/threshold_evaluator.dart';
import 'package:notifications_domain/src/models/notification_event.dart';
import 'package:notifications_domain/src/models/notification_kind.dart';
import 'package:notifications_domain/src/models/threshold_breach.dart';
import 'package:notifications_domain/src/repositories/i_notification_sender.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template evaluate_and_notify_command}
/// Evaluates a [Reading] against a user's [ThresholdSettings] and notifies
/// the user, via an [INotificationSender], only when the breach state
/// changes — i.e. a newly-breached threshold, or a newly-restored one.
///
/// While a threshold stays breached across repeated checks, no further
/// notification is sent, so the user is never spammed.
/// {@endtemplate}
class EvaluateAndNotifyCommand {
  /// {@macro evaluate_and_notify_command}
  const EvaluateAndNotifyCommand({
    required this._evaluator,
    required this._sender,
  });

  final ThresholdEvaluator _evaluator;
  final INotificationSender _sender;

  /// Evaluates [reading] against [settings], compares the result with
  /// [previousBreach], and sends a notification if the breach state
  /// changed. Returns the newly-evaluated [ThresholdBreach].
  Future<ThresholdBreach> execute({
    required Reading reading,
    required ThresholdSettings settings,
    required ThresholdBreach previousBreach,
  }) async {
    final breach = _evaluator.evaluate(reading: reading, settings: settings);

    if (breach != ThresholdBreach.none && breach != previousBreach) {
      await _sender.send(_buildBreachEvent(breach, reading, settings));
    } else if (breach == ThresholdBreach.none &&
        previousBreach != ThresholdBreach.none) {
      await _sender.send(_buildRestoredEvent(reading, settings));
    }

    return breach;
  }

  NotificationEvent _buildBreachEvent(
    ThresholdBreach breach,
    Reading reading,
    ThresholdSettings settings,
  ) {
    final current = reading.roomTemperatureCelsius.toStringAsFixed(1);
    final limit = breach == ThresholdBreach.belowMinimum
        ? settings.minCelsius.toStringAsFixed(1)
        : settings.maxCelsius.toStringAsFixed(1);
    final direction = breach == ThresholdBreach.belowMinimum
        ? 'below'
        : 'above';

    return NotificationEvent(
      title: 'Room temperature alert',
      body: 'Room is now $current°C, $direction your $limit°C limit.',
      kind: NotificationKind.thresholdBreached,
      triggeredAt: reading.timestamp,
    );
  }

  NotificationEvent _buildRestoredEvent(
    Reading reading,
    ThresholdSettings settings,
  ) {
    final current = reading.roomTemperatureCelsius.toStringAsFixed(1);
    final min = settings.minCelsius.toStringAsFixed(1);
    final max = settings.maxCelsius.toStringAsFixed(1);

    return NotificationEvent(
      title: 'Room temperature back to normal',
      body: 'Room is now $current°C, within your $min°C–$max°C range.',
      kind: NotificationKind.thresholdRestored,
      triggeredAt: reading.timestamp,
    );
  }
}
