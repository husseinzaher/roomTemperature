/// Converts battery temperature into an estimated room temperature.
///
/// Combines Newton's cooling lag
/// `T_room = T_batt + (1/k) * dT_batt/dt`
/// with electrical self-heating
/// `T_room = T_batt - (c * I * V)`
/// into the single model
/// `T_room = T_batt + (1/k) * dT_batt/dt - (c * I * V)`.
class BatteryRoomTemperatureModel {
  /// Creates a battery-to-room model.
  const BatteryRoomTemperatureModel({
    required this.couplingKPerSecond,
    required this.selfHeatCoefficient,
    this.maxLagCorrectionCelsius = 5,
    this.maxSelfHeatCorrectionCelsius = 8,
  });

  /// Thermal coupling `k` in 1/seconds (`τ = 1/k`).
  final double couplingKPerSecond;

  /// Self-heating coefficient `c` in °C per watt.
  final double selfHeatCoefficient;

  /// Clamp for the lag term `(1/k) * dT/dt`.
  final double maxLagCorrectionCelsius;

  /// Clamp for the heating term `c * I * V`.
  final double maxSelfHeatCorrectionCelsius;

  /// Evaluates both equations for one sample.
  BatteryRoomTemperatureTerms evaluate({
    required double batteryCelsius,
    double dBatteryCelsiusPerSecond = 0,
    double currentAmps = 0,
    double voltageVolts = 0,
  }) {
    final k = couplingKPerSecond;
    final lag = k > 0 && k.isFinite
        ? (1 / k) * dBatteryCelsiusPerSecond
        : 0.0;
    final heat =
        selfHeatCoefficient * currentAmps.abs() * voltageVolts.abs();
    final clampedLag = _clamp(
      lag,
      -maxLagCorrectionCelsius,
      maxLagCorrectionCelsius,
    );
    final clampedHeat = _clamp(
      heat,
      0,
      maxSelfHeatCorrectionCelsius,
    );
    return BatteryRoomTemperatureTerms(
      batteryCelsius: batteryCelsius,
      dBatteryCelsiusPerSecond: dBatteryCelsiusPerSecond,
      currentAmps: currentAmps.abs(),
      voltageVolts: voltageVolts.abs(),
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
    required this.currentAmps,
    required this.voltageVolts,
    required this.lagCorrectionCelsius,
    required this.selfHeatCorrectionCelsius,
    required this.roomCelsius,
  });

  /// `T_batt`.
  final double batteryCelsius;

  /// `dT_batt/dt` in °C/s.
  final double dBatteryCelsiusPerSecond;

  /// `|I|` in amps.
  final double currentAmps;

  /// `|V|` in volts.
  final double voltageVolts;

  /// `(1/k) * dT_batt/dt` after clamping.
  final double lagCorrectionCelsius;

  /// `c * I * V` after clamping.
  final double selfHeatCorrectionCelsius;

  /// Combined `T_room`.
  final double roomCelsius;

  /// Instantaneous electrical power `I * V`.
  double get powerWatts => currentAmps * voltageVolts;
}

/// Finite-difference helper for `dT_batt/dt`.
///
/// Returns `null` until two battery samples exist so the first real
/// derivative is used raw instead of being EMA'd toward zero.
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
