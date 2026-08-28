/// Converts battery temperature into a physics-based room estimate.
///
/// First-order thermal model:
/// `dT_batt/dt = (T_room - T_batt + R_th * P) / tau`
/// therefore
/// `T_room = T_batt + tau * dT_batt/dt - R_th * P`.
///
/// `P` is a *load proxy* (`|I| * V`), not claimed to be battery heat.
/// When `P` is unavailable the heat term is omitted — it is not treated
/// as zero with fake certainty.
class BatteryRoomTemperatureModel {
  /// Creates a battery-to-room model.
  const BatteryRoomTemperatureModel({
    required this.tauSeconds,
    required this.rTh,
    this.maxLagCorrectionCelsius = 5,
    this.maxSelfHeatCorrectionCelsius = 8,
  });

  /// Thermal time constant `tau` in seconds.
  final double tauSeconds;

  /// Effective thermal resistance `R_th` in °C/W.
  final double rTh;

  /// Clamp for the lag term `tau * dT/dt`.
  final double maxLagCorrectionCelsius;

  /// Clamp for the heating term `R_th * P`.
  final double maxSelfHeatCorrectionCelsius;

  /// Evaluates the model for one sample.
  BatteryRoomTemperatureTerms evaluate({
    required double batteryCelsius,
    double dBatteryCelsiusPerSecond = 0,
    double? powerWatts,
  }) {
    final tau = tauSeconds > 0 && tauSeconds.isFinite ? tauSeconds : 0.0;
    final lag = tau * dBatteryCelsiusPerSecond;
    final powerAvailable = powerWatts != null && powerWatts.isFinite;
    final heat = powerAvailable ? rTh * powerWatts : 0.0;
    final clampedLag = _clamp(
      lag,
      -maxLagCorrectionCelsius,
      maxLagCorrectionCelsius,
    );
    final clampedHeat = _clamp(heat, 0, maxSelfHeatCorrectionCelsius);
    return BatteryRoomTemperatureTerms(
      batteryCelsius: batteryCelsius,
      dBatteryCelsiusPerSecond: dBatteryCelsiusPerSecond,
      powerWatts: powerAvailable ? powerWatts : null,
      powerAvailable: powerAvailable,
      tauSeconds: tau,
      rTh: rTh,
      lagCorrectionCelsius: clampedLag,
      selfHeatCorrectionCelsius: clampedHeat,
      roomCelsius: batteryCelsius + clampedLag - clampedHeat,
    );
  }
}

double _clamp(double value, double min, double max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

/// Intermediate terms of [BatteryRoomTemperatureModel.evaluate].
class BatteryRoomTemperatureTerms {
  /// Creates evaluated terms.
  const BatteryRoomTemperatureTerms({
    required this.batteryCelsius,
    required this.dBatteryCelsiusPerSecond,
    required this.powerWatts,
    required this.powerAvailable,
    required this.tauSeconds,
    required this.rTh,
    required this.lagCorrectionCelsius,
    required this.selfHeatCorrectionCelsius,
    required this.roomCelsius,
  });

  /// `T_batt`.
  final double batteryCelsius;

  /// `dT_batt/dt` in °C/s.
  final double dBatteryCelsiusPerSecond;

  /// Load proxy `P = |I| * V` in watts, or `null` when unavailable.
  final double? powerWatts;

  /// Whether [powerWatts] was observed (not invented).
  final bool powerAvailable;

  /// `tau` used for this sample.
  final double tauSeconds;

  /// `R_th` used for this sample.
  final double rTh;

  /// `tau * dT_batt/dt` after clamping.
  final double lagCorrectionCelsius;

  /// `R_th * P` after clamping, or 0 when [powerAvailable] is false.
  final double selfHeatCorrectionCelsius;

  /// Combined `T_room`.
  final double roomCelsius;
}

/// Finite-difference helper for `dT_batt/dt`.
///
/// Returns `null` until two battery samples exist so the first real
/// derivative is used raw instead of being EMA'd toward zero.
/// Samples closer together than [minSampleDuration] keep the previous
/// derivative rather than inventing a noisy spike.
double? batteryTemperatureDerivativePerSecond({
  required double batteryCelsius,
  required DateTime at,
  required double? previousBatteryCelsius,
  required DateTime? previousAt,
  required Duration minSampleDuration,
  required double maxAbsPerSecond,
  double? previousSmoothed,
}) {
  if (previousBatteryCelsius == null || previousAt == null) {
    return null;
  }
  final dtSeconds = at.difference(previousAt).inMilliseconds / 1000.0;
  if (dtSeconds <= 0 || dtSeconds.isNaN) {
    return previousSmoothed;
  }
  if (dtSeconds > 30 * 60) {
    return 0;
  }
  if (dtSeconds < minSampleDuration.inMilliseconds / 1000.0) {
    return previousSmoothed;
  }
  final raw = _clamp(
    (batteryCelsius - previousBatteryCelsius) / dtSeconds,
    -maxAbsPerSecond,
    maxAbsPerSecond,
  );
  if (previousSmoothed == null) {
    return raw;
  }
  return previousSmoothed + (raw - previousSmoothed) * 0.35;
}
