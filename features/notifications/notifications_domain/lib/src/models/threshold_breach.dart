/// Whether a room temperature reading breaches a configured threshold
/// range, and in which direction.
enum ThresholdBreach {
  /// The room temperature is within the configured range (or thresholds are
  /// disabled).
  none,

  /// The room temperature is below the configured minimum.
  belowMinimum,

  /// The room temperature is above the configured maximum.
  aboveMaximum,
}
