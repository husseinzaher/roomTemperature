/// Snapshot of the local indoor estimator for the settings calibration card.
class IndoorCalibrationView {
  /// Creates a calibration view model.
  const IndoorCalibrationView({
    this.estimateCelsius,
    this.confidence,
    this.statusLabel = 'Learning baseline',
    this.hasCalibration = false,
    this.debugText,
  });

  /// Latest indoor estimate, if one has been produced.
  final double? estimateCelsius;

  /// 0–1 confidence of that estimate.
  final double? confidence;

  /// Short status: Calibrated / Learning baseline / Low confidence.
  final String statusLabel;

  /// Whether any calibration points are stored.
  final bool hasCalibration;

  /// Debug dump, shown only when the host supplies it.
  final String? debugText;
}

/// Host callbacks for indoor calibration, injected by the app shell.
class IndoorCalibrationHost {
  /// Creates a calibration host.
  const IndoorCalibrationHost({
    required this.load,
    required this.calibrate,
    required this.reset,
  });

  /// Loads the current estimate and status.
  final Future<IndoorCalibrationView> Function() load;

  /// Stores a manual reference temperature.
  final Future<({bool saved, bool poorConditions})> Function(
    double actualCelsius,
  )
  calibrate;

  /// Clears stored calibration points.
  final Future<void> Function() reset;
}
