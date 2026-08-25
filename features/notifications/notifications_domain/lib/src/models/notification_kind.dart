/// The kind of event a notification event represents.
enum NotificationKind {
  /// The room temperature newly crossed a configured threshold.
  thresholdBreached,

  /// The room temperature returned to within the configured range after
  /// having breached it.
  thresholdRestored,
}
