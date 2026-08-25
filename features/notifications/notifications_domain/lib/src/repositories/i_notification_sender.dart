import 'package:notifications_domain/src/models/notification_event.dart';

/// {@template i_notification_sender}
/// Delivers a [NotificationEvent] to the user.
/// {@endtemplate}
// ignore: one_member_abstracts
abstract interface class INotificationSender {
  /// Sends [event] to the user.
  Future<void> send(NotificationEvent event);
}
