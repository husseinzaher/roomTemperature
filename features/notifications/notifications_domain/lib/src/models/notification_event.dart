import 'package:equatable/equatable.dart';
import 'package:notifications_domain/src/models/notification_kind.dart';

/// {@template notification_event}
/// A notification ready to be delivered to a user, describing a threshold
/// breach or restoration.
/// {@endtemplate}
class NotificationEvent extends Equatable {
  /// {@macro notification_event}
  const NotificationEvent({
    required this.title,
    required this.body,
    required this.kind,
    required this.triggeredAt,
  });

  /// The notification's title.
  final String title;

  /// The notification's body text.
  final String body;

  /// The kind of event this notification represents.
  final NotificationKind kind;

  /// When this event was triggered.
  final DateTime triggeredAt;

  @override
  List<Object?> get props => [title, body, kind, triggeredAt];
}
