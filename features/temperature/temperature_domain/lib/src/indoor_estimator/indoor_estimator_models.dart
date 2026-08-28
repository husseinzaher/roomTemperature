import 'package:equatable/equatable.dart';
import 'package:temperature_domain/src/indoor_estimator/thermal_snapshot.dart';

/// Heuristic class of a thermal zone.
enum ThermalZoneClass {
  /// Name and/or behaviour look like skin / board / environment.
  environmental,

  /// Unknown zone that still behaves like an environmental proxy.
  candidate,

  /// Internal component (CPU, GPU, PA, PMIC, …).
  component,

  /// Impossible, stuck, stale, or otherwise unusable.
  invalid,
}

/// Score breakdown for one thermal zone.
class ScoredThermalZone extends Equatable {
  /// Creates a scored thermal zone.
  const ScoredThermalZone({
    required this.name,
    required this.temperatureCelsius,
    required this.classification,
    required this.environmentScore,
    required this.nameScore,
    required this.plausibilityScore,
    required this.stabilityScore,
    required this.lowCpuCorrelationScore,
    required this.heatingCoolingScore,
    required this.historicalReliabilityScore,
    this.rejectReason,
  });

  /// Zone type name.
  final String name;

  /// Current Celsius reading.
  final double temperatureCelsius;

  /// Heuristic class.
  final ThermalZoneClass classification;

  /// Combined 0–1 environment-proxy score.
  final double environmentScore;

  /// Name-prior component of the score.
  final double nameScore;

  /// Whether the current value is a plausible skin/environment proxy.
  final double plausibilityScore;

  /// Inverse of recent variance.
  final double stabilityScore;

  /// 1 when the zone does not track CPU heat.
  final double lowCpuCorrelationScore;

  /// How the zone behaved during recent heating/cooling.
  final double heatingCoolingScore;

  /// Long-run reliability vs other signals.
  final double historicalReliabilityScore;

  /// Why this zone was discarded, if it was.
  final String? rejectReason;

  /// Whether this zone may be used as an environmental proxy.
  bool get isSelectable =>
      classification != ThermalZoneClass.invalid &&
      classification != ThermalZoneClass.component &&
      rejectReason == null &&
      environmentScore >= 0.28;

  @override
  List<Object?> get props => [
    name,
    temperatureCelsius,
    classification,
    environmentScore,
    rejectReason,
  ];
}

/// Debug dump of one estimator pass. Debug-only UI; not shown to users.
class IndoorEstimateDebug extends Equatable {
  /// Creates an estimator debug dump.
  const IndoorEstimateDebug({
    required this.batteryCelsius,
    required this.isCharging,
    required this.thermalStatus,
    required this.zones,
    required this.selectedSensors,
    required this.rawEstimateCelsius,
    required this.finalEstimateCelsius,
    required this.confidence,
    required this.calibrationApplied,
    required this.calibrationOffsetCelsius,
    required this.baselineQuality,
    required this.networkRequired,
    this.cpuCelsius,
    this.gpuCelsius,
    this.screenOn,
    this.cpuUsagePercent,
    this.statusLabel,
    this.batteryDerivativePerSecond,
    this.lagCorrectionCelsius,
    this.selfHeatCorrectionCelsius,
    this.batteryCurrentAmps,
    this.batteryVoltageVolts,
  });

  /// Battery temperature, if known.
  final double? batteryCelsius;

  /// Charging flag.
  final bool isCharging;

  /// Android thermal status integer, if known.
  final int? thermalStatus;

  /// Every scored zone.
  final List<ScoredThermalZone> zones;

  /// Names of sensors that contributed to the raw estimate.
  final List<String> selectedSensors;

  /// Estimate before calibration and smoothing.
  final double? rawEstimateCelsius;

  /// Smoothed, calibrated estimate.
  final double finalEstimateCelsius;

  /// 0–1 confidence.
  final double confidence;

  /// Whether a calibration profile was applied.
  final bool calibrationApplied;

  /// Effective calibration offset at this sample, if any.
  final double? calibrationOffsetCelsius;

  /// 0–1 quality of the stored idle baseline, 0 if none.
  final double baselineQuality;

  /// Always `false` — indoor estimation never uses the network.
  final bool networkRequired;

  /// Mean CPU-cluster temperature, if known.
  final double? cpuCelsius;

  /// Mean GPU temperature, if known.
  final double? gpuCelsius;

  /// Screen interactive flag.
  final bool? screenOn;

  /// CPU usage percent.
  final double? cpuUsagePercent;

  /// User-facing status: calibrated / learning / low confidence.
  final String? statusLabel;

  /// `dT_batt/dt` used in the battery-physics model, if any.
  final double? batteryDerivativePerSecond;

  /// `(1/k) * dT_batt/dt` lag term, if battery physics ran.
  final double? lagCorrectionCelsius;

  /// `c * I * V` self-heating term, if battery physics ran.
  final double? selfHeatCorrectionCelsius;

  /// `|I|` in amps used by the self-heating term.
  final double? batteryCurrentAmps;

  /// `|V|` in volts used by the self-heating term.
  final double? batteryVoltageVolts;

  /// Multi-line dump for the debug panel.
  String format() {
    final buffer = StringBuffer()
      ..writeln('Indoor Temperature Debug')
      ..writeln()
      ..writeln(
        'Battery: ${batteryCelsius?.toStringAsFixed(1) ?? 'n/a'}°C',
      )
      ..writeln('Charging: $isCharging')
      ..writeln('Thermal State: ${thermalStatus ?? 'n/a'}')
      ..writeln('CPU: ${cpuCelsius?.toStringAsFixed(1) ?? 'n/a'}°C')
      ..writeln('GPU: ${gpuCelsius?.toStringAsFixed(1) ?? 'n/a'}°C')
      ..writeln(
        'CPU load: ${cpuUsagePercent?.toStringAsFixed(0) ?? 'n/a'}%',
      )
      ..writeln()
      ..writeln('Candidate sensors:');
    for (final zone in zones) {
      buffer
        ..writeln()
        ..writeln('${zone.name}:')
        ..writeln('${zone.temperatureCelsius.toStringAsFixed(1)}°C')
        ..writeln('score: ${zone.environmentScore.toStringAsFixed(2)}')
        ..writeln('class: ${zone.classification.name}');
      if (zone.rejectReason != null) {
        buffer.writeln('reason: ${zone.rejectReason}');
      }
    }
    buffer
      ..writeln()
      ..writeln('Selected sensors:')
      ..writeln(selectedSensors.isEmpty ? '(none)' : selectedSensors.join(', '))
      ..writeln()
      ..writeln(
        'Raw estimate: '
        '${rawEstimateCelsius?.toStringAsFixed(2) ?? 'n/a'}°C',
      )
      ..writeln('Calibration: ${calibrationApplied ? 'enabled' : 'none'}')
      ..writeln(
        'Calibration offset: '
        '${calibrationOffsetCelsius?.toStringAsFixed(2) ?? 'n/a'}°C',
      )
      ..writeln(
        'Final estimate: ${finalEstimateCelsius.toStringAsFixed(2)}°C',
      )
      ..writeln('Confidence: ${confidence.toStringAsFixed(2)}')
      ..writeln('Network required: $networkRequired');
    if (lagCorrectionCelsius != null ||
        selfHeatCorrectionCelsius != null) {
      buffer
        ..writeln()
        ..writeln('T_room = T_batt + (1/k)·dT/dt − c·I·V')
        ..writeln(
          'dT/dt: '
          '${batteryDerivativePerSecond?.toStringAsFixed(4) ?? 'n/a'} °C/s',
        )
        ..writeln(
          'I: ${batteryCurrentAmps?.toStringAsFixed(3) ?? 'n/a'} A',
        )
        ..writeln(
          'V: ${batteryVoltageVolts?.toStringAsFixed(2) ?? 'n/a'} V',
        )
        ..writeln(
          '(1/k)·dT/dt: '
          '${lagCorrectionCelsius?.toStringAsFixed(2) ?? 'n/a'}°C',
        )
        ..writeln(
          'c·I·V: '
          '${selfHeatCorrectionCelsius?.toStringAsFixed(2) ?? 'n/a'}°C',
        );
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
    batteryCelsius,
    isCharging,
    thermalStatus,
    zones,
    selectedSensors,
    rawEstimateCelsius,
    finalEstimateCelsius,
    confidence,
    calibrationApplied,
    calibrationOffsetCelsius,
    baselineQuality,
    networkRequired,
  ];
}

/// Result of one indoor estimate.
class IndoorEstimateResult extends Equatable {
  /// Creates an indoor estimate result.
  const IndoorEstimateResult({
    required this.temperatureCelsius,
    required this.confidence,
    required this.selectedSensors,
    required this.calibrationApplied,
    required this.debug,
  });

  /// Estimated indoor temperature in Celsius (smoothed).
  final double temperatureCelsius;

  /// 0–1 confidence. Low values mean the UI must not look precise.
  final double confidence;

  /// Sensors that contributed to the raw estimate.
  final List<String> selectedSensors;

  /// Whether a stored calibration profile was applied.
  final bool calibrationApplied;

  /// Debug dump of this pass.
  final IndoorEstimateDebug debug;

  /// Temperature rounded for display according to [confidence].
  double get displayCelsius {
    if (confidence >= 0.7) {
      return (temperatureCelsius * 10).round() / 10;
    }
    return temperatureCelsius.roundToDouble();
  }

  /// Whether the UI should prefix the value with ≈.
  bool get isApproximate => confidence < 0.45;

  @override
  List<Object?> get props => [
    temperatureCelsius,
    confidence,
    selectedSensors,
    calibrationApplied,
    debug,
  ];
}

/// One manual (or auto) calibration sample stored on device.
class IndoorCalibrationPoint extends Equatable {
  /// Creates a calibration point.
  const IndoorCalibrationPoint({
    required this.timestamp,
    required this.rawEstimateCelsius,
    required this.actualRoomCelsius,
    required this.selectedSensors,
    required this.sensorValues,
    required this.isCharging,
    required this.confidence,
    required this.usedForModel,
    this.batteryCelsius,
    this.cpuCelsius,
    this.thermalStatus,
    this.poorConditions = false,
  });

  /// Builds a point from persisted JSON.
  factory IndoorCalibrationPoint.fromJson(Map<String, dynamic> json) {
    final rawSensors = json['sensorValues'];
    final sensorValues = <String, double>{};
    if (rawSensors is Map) {
      for (final entry in rawSensors.entries) {
        final value = entry.value;
        if (value is num) {
          sensorValues['${entry.key}'] = value.toDouble();
        }
      }
    }
    return IndoorCalibrationPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestampMs'] as num).toInt(),
      ),
      rawEstimateCelsius: (json['rawEstimateCelsius'] as num).toDouble(),
      actualRoomCelsius: (json['actualRoomCelsius'] as num).toDouble(),
      batteryCelsius: (json['batteryCelsius'] as num?)?.toDouble(),
      cpuCelsius: (json['cpuCelsius'] as num?)?.toDouble(),
      selectedSensors: [
        if (json['selectedSensors'] is List)
          for (final name in json['selectedSensors'] as List) '$name',
      ],
      sensorValues: sensorValues,
      isCharging: json['isCharging'] as bool? ?? false,
      thermalStatus: (json['thermalStatus'] as num?)?.toInt(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      usedForModel: json['usedForModel'] as bool? ?? true,
      poorConditions: json['poorConditions'] as bool? ?? false,
    );
  }

  /// When the user (or auto-baseline) captured this point.
  final DateTime timestamp;

  /// Estimator output before applying this point.
  final double rawEstimateCelsius;

  /// User-entered (or learned) actual room temperature.
  final double actualRoomCelsius;

  /// Battery temperature at capture.
  final double? batteryCelsius;

  /// CPU-cluster temperature at capture.
  final double? cpuCelsius;

  /// Sensors selected at capture.
  final List<String> selectedSensors;

  /// All usable sensor values at capture.
  final Map<String, double> sensorValues;

  /// Charging flag at capture.
  final bool isCharging;

  /// Android thermal status at capture.
  final int? thermalStatus;

  /// Estimator confidence at capture.
  final double confidence;

  /// Whether this point participates in the regression/offset model.
  final bool usedForModel;

  /// Whether device conditions were poor (warning for manual points).
  final bool poorConditions;

  /// `actual - raw` offset at this point.
  double get offsetCelsius => actualRoomCelsius - rawEstimateCelsius;

  /// JSON for local persistence.
  Map<String, Object?> toJson() => {
    'timestampMs': timestamp.millisecondsSinceEpoch,
    'rawEstimateCelsius': rawEstimateCelsius,
    'actualRoomCelsius': actualRoomCelsius,
    'batteryCelsius': batteryCelsius,
    'cpuCelsius': cpuCelsius,
    'selectedSensors': selectedSensors,
    'sensorValues': sensorValues,
    'isCharging': isCharging,
    'thermalStatus': thermalStatus,
    'confidence': confidence,
    'usedForModel': usedForModel,
    'poorConditions': poorConditions,
  };

  @override
  List<Object?> get props => [
    timestamp,
    rawEstimateCelsius,
    actualRoomCelsius,
    batteryCelsius,
    selectedSensors,
    usedForModel,
  ];
}

/// Idle thermal signature captured when the device has sat still.
class IndoorBaseline extends Equatable {
  /// Creates an idle baseline.
  const IndoorBaseline({
    required this.timestamp,
    required this.selectedSensors,
    required this.sensorValues,
    required this.stability,
    required this.isCharging,
    this.batteryCelsius,
  });

  /// Builds a baseline from persisted JSON.
  factory IndoorBaseline.fromJson(Map<String, dynamic> json) {
    final rawSensors = json['sensorValues'];
    final sensorValues = <String, double>{};
    if (rawSensors is Map) {
      for (final entry in rawSensors.entries) {
        final value = entry.value;
        if (value is num) {
          sensorValues['${entry.key}'] = value.toDouble();
        }
      }
    }
    return IndoorBaseline(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestampMs'] as num).toInt(),
      ),
      selectedSensors: [
        if (json['selectedSensors'] is List)
          for (final name in json['selectedSensors'] as List) '$name',
      ],
      sensorValues: sensorValues,
      batteryCelsius: (json['batteryCelsius'] as num?)?.toDouble(),
      stability: (json['stability'] as num?)?.toDouble() ?? 0,
      isCharging: json['isCharging'] as bool? ?? false,
    );
  }

  /// When the baseline was locked in.
  final DateTime timestamp;

  /// Sensors that looked environmental at lock-in.
  final List<String> selectedSensors;

  /// Zone/battery values at lock-in.
  final Map<String, double> sensorValues;

  /// Battery temperature at lock-in.
  final double? batteryCelsius;

  /// 0–1 stability of the window that produced this baseline.
  final double stability;

  /// Always false for a valid auto baseline.
  final bool isCharging;

  /// JSON for local persistence.
  Map<String, Object?> toJson() => {
    'timestampMs': timestamp.millisecondsSinceEpoch,
    'selectedSensors': selectedSensors,
    'sensorValues': sensorValues,
    'batteryCelsius': batteryCelsius,
    'stability': stability,
    'isCharging': isCharging,
  };

  @override
  List<Object?> get props => [timestamp, selectedSensors, stability];
}

/// On-device calibration profile: points + optional idle baseline.
class IndoorCalibrationProfile extends Equatable {
  /// Creates a calibration profile.
  const IndoorCalibrationProfile({
    this.points = const [],
    this.baseline,
  });

  /// Builds a profile from persisted JSON.
  factory IndoorCalibrationProfile.fromJson(Map<String, dynamic> json) {
    return IndoorCalibrationProfile(
      points: [
        if (json['points'] is List)
          for (final point in json['points'] as List)
            if (point is Map)
              IndoorCalibrationPoint.fromJson(
                Map<String, dynamic>.from(point),
              ),
      ],
      baseline: json['baseline'] is Map
          ? IndoorBaseline.fromJson(
              Map<String, dynamic>.from(json['baseline'] as Map),
            )
          : null,
    );
  }

  /// Empty profile.
  static const empty = IndoorCalibrationProfile();

  /// Manual (and rare auto) calibration points, newest last.
  final List<IndoorCalibrationPoint> points;

  /// Last idle baseline, if one has been learned.
  final IndoorBaseline? baseline;

  /// Points allowed to drive the correction model.
  List<IndoorCalibrationPoint> get modelPoints => [
    for (final point in points)
      if (point.usedForModel) point,
  ];

  /// Whether any usable calibration exists.
  bool get hasCalibration => modelPoints.isNotEmpty;

  /// JSON for local persistence.
  Map<String, Object?> toJson() => {
    'points': [for (final point in points) point.toJson()],
    'baseline': baseline?.toJson(),
  };

  /// Copy with replaced fields.
  IndoorCalibrationProfile copyWith({
    List<IndoorCalibrationPoint>? points,
    IndoorBaseline? baseline,
    bool clearBaseline = false,
  }) {
    return IndoorCalibrationProfile(
      points: points ?? this.points,
      baseline: clearBaseline ? null : (baseline ?? this.baseline),
    );
  }

  @override
  List<Object?> get props => [points, baseline];
}

/// Running per-zone samples used for scoring.
class ZoneHistory extends Equatable {
  /// Creates a zone history.
  const ZoneHistory({
    required this.samples,
    required this.lastChangedAt,
    required this.lastValue,
  });

  /// Builds history from persisted JSON.
  factory ZoneHistory.fromJson(Map<String, dynamic> json) {
    return ZoneHistory(
      samples: [
        if (json['samples'] is List)
          for (final sample in json['samples'] as List)
            if (sample is num) sample.toDouble(),
      ],
      lastChangedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['lastChangedAtMs'] as num).toInt(),
      ),
      lastValue: (json['lastValue'] as num).toDouble(),
    );
  }

  /// Recent Celsius samples, oldest first.
  final List<double> samples;

  /// Last time the value moved by more than a tiny epsilon.
  final DateTime lastChangedAt;

  /// Most recent value.
  final double lastValue;

  /// JSON for persistence.
  Map<String, Object?> toJson() => {
    'samples': samples,
    'lastChangedAtMs': lastChangedAt.millisecondsSinceEpoch,
    'lastValue': lastValue,
  };

  @override
  List<Object?> get props => [samples, lastChangedAt, lastValue];
}

/// Mutable-across-calls estimator memory. Persisted locally.
class IndoorEstimatorState extends Equatable {
  /// Creates estimator state.
  const IndoorEstimatorState({
    this.emaCelsius,
    this.lastEmittedAt,
    this.idleStableSince,
    this.zoneHistories = const {},
    this.lastCpuCelsius,
    this.lastSelectedProxyCelsius,
    this.lastBatteryCelsius,
    this.lastBatterySampledAt,
    this.smoothedBatteryDerivativePerSecond,
  });

  /// Builds state from persisted JSON.
  factory IndoorEstimatorState.fromJson(Map<String, dynamic> json) {
    final rawHistories = json['zoneHistories'];
    final histories = <String, ZoneHistory>{};
    if (rawHistories is Map) {
      for (final entry in rawHistories.entries) {
        final value = entry.value;
        if (value is Map) {
          histories['${entry.key}'] = ZoneHistory.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      }
    }
    return IndoorEstimatorState(
      emaCelsius: (json['emaCelsius'] as num?)?.toDouble(),
      lastEmittedAt: json['lastEmittedAtMs'] is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['lastEmittedAtMs'] as num).toInt(),
            )
          : null,
      idleStableSince: json['idleStableSinceMs'] is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['idleStableSinceMs'] as num).toInt(),
            )
          : null,
      zoneHistories: histories,
      lastCpuCelsius: (json['lastCpuCelsius'] as num?)?.toDouble(),
      lastSelectedProxyCelsius: (json['lastSelectedProxyCelsius'] as num?)
          ?.toDouble(),
      lastBatteryCelsius: (json['lastBatteryCelsius'] as num?)?.toDouble(),
      lastBatterySampledAt: json['lastBatterySampledAtMs'] is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['lastBatterySampledAtMs'] as num).toInt(),
            )
          : null,
      smoothedBatteryDerivativePerSecond:
          (json['smoothedBatteryDerivativePerSecond'] as num?)?.toDouble(),
    );
  }

  /// Empty state.
  static const empty = IndoorEstimatorState();

  /// Last smoothed indoor estimate.
  final double? emaCelsius;

  /// When [emaCelsius] was last updated.
  final DateTime? lastEmittedAt;

  /// Start of the current idle-and-stable window, if any.
  final DateTime? idleStableSince;

  /// Per-zone sample histories.
  final Map<String, ZoneHistory> zoneHistories;

  /// CPU temperature at the previous snapshot, for spike detection.
  final double? lastCpuCelsius;

  /// Selected environmental-proxy temperature at the previous snapshot.
  final double? lastSelectedProxyCelsius;

  /// Battery temperature at the previous snapshot, for `dT_batt/dt`.
  final double? lastBatteryCelsius;

  /// When [lastBatteryCelsius] was sampled.
  final DateTime? lastBatterySampledAt;

  /// Smoothed `dT_batt/dt` in °C/s.
  final double? smoothedBatteryDerivativePerSecond;

  /// JSON for persistence.
  Map<String, Object?> toJson() => {
    'emaCelsius': emaCelsius,
    'lastEmittedAtMs': lastEmittedAt?.millisecondsSinceEpoch,
    'idleStableSinceMs': idleStableSince?.millisecondsSinceEpoch,
    'zoneHistories': {
      for (final entry in zoneHistories.entries)
        entry.key: entry.value.toJson(),
    },
    'lastCpuCelsius': lastCpuCelsius,
    'lastSelectedProxyCelsius': lastSelectedProxyCelsius,
    'lastBatteryCelsius': lastBatteryCelsius,
    'lastBatterySampledAtMs': lastBatterySampledAt?.millisecondsSinceEpoch,
    'smoothedBatteryDerivativePerSecond':
        smoothedBatteryDerivativePerSecond,
  };

  /// Copy with replaced fields.
  IndoorEstimatorState copyWith({
    double? emaCelsius,
    DateTime? lastEmittedAt,
    DateTime? idleStableSince,
    Map<String, ZoneHistory>? zoneHistories,
    double? lastCpuCelsius,
    double? lastSelectedProxyCelsius,
    double? lastBatteryCelsius,
    DateTime? lastBatterySampledAt,
    double? smoothedBatteryDerivativePerSecond,
    bool clearIdleStableSince = false,
  }) {
    return IndoorEstimatorState(
      emaCelsius: emaCelsius ?? this.emaCelsius,
      lastEmittedAt: lastEmittedAt ?? this.lastEmittedAt,
      idleStableSince: clearIdleStableSince
          ? null
          : (idleStableSince ?? this.idleStableSince),
      zoneHistories: zoneHistories ?? this.zoneHistories,
      lastCpuCelsius: lastCpuCelsius ?? this.lastCpuCelsius,
      lastSelectedProxyCelsius:
          lastSelectedProxyCelsius ?? this.lastSelectedProxyCelsius,
      lastBatteryCelsius: lastBatteryCelsius ?? this.lastBatteryCelsius,
      lastBatterySampledAt:
          lastBatterySampledAt ?? this.lastBatterySampledAt,
      smoothedBatteryDerivativePerSecond:
          smoothedBatteryDerivativePerSecond ??
          this.smoothedBatteryDerivativePerSecond,
    );
  }

  @override
  List<Object?> get props => [
    emaCelsius,
    lastEmittedAt,
    idleStableSince,
    zoneHistories,
    lastCpuCelsius,
    lastSelectedProxyCelsius,
    lastBatteryCelsius,
    lastBatterySampledAt,
    smoothedBatteryDerivativePerSecond,
  ];
}

/// One estimator step: result plus updated local state/profile.
class IndoorEstimateStep extends Equatable {
  /// Creates an estimator step.
  const IndoorEstimateStep({
    required this.state,
    required this.profile,
    this.result,
  });

  /// The indoor estimate, or `null` when no usable thermal signal exists.
  final IndoorEstimateResult? result;

  /// Updated running state to persist.
  final IndoorEstimatorState state;

  /// Profile, possibly with a newly learned baseline.
  final IndoorCalibrationProfile profile;

  @override
  List<Object?> get props => [result, state, profile];
}

/// Tunable estimator parameters. Production uses [standard].
class IndoorEstimatorConfig extends Equatable {
  /// Creates estimator config.
  const IndoorEstimatorConfig({
    this.baselineStableDuration = const Duration(minutes: 15),
    this.baselineMinSamples = 4,
    this.maxDisplayDeltaPerMinute = 0.12,
    this.emaTimeConstant = const Duration(minutes: 8),
    this.historyLimit = 24,
    this.maxCalibrationPoints = 12,
    this.batteryCouplingKPerSecond = 1 / 600,
    this.batterySelfHeatCoefficient = 0.8,
    this.maxLagCorrectionCelsius = 5,
    this.maxSelfHeatCorrectionCelsius = 8,
    this.minBatteryDerivativeDuration = const Duration(seconds: 20),
    this.maxBatteryDerivativePerSecond = 0.01,
  });

  /// Production defaults.
  static const standard = IndoorEstimatorConfig();

  /// How long the device must sit idle and stable before a baseline locks.
  final Duration baselineStableDuration;

  /// Minimum snapshots in the idle window.
  final int baselineMinSamples;

  /// Hard rate limit on the displayed indoor value.
  final double maxDisplayDeltaPerMinute;

  /// EMA time constant for following slow environmental change.
  final Duration emaTimeConstant;

  /// Samples kept per zone.
  final int historyLimit;

  /// Cap on stored calibration points.
  final int maxCalibrationPoints;

  /// Thermal coupling `k` in 1/seconds for
  /// `T_room = T_batt + (1/k) * dT_batt/dt`.
  ///
  /// Default `1/600` is a 10-minute battery-to-ambient time constant.
  final double batteryCouplingKPerSecond;

  /// Self-heating coefficient `c` in °C/W for
  /// `T_room = T_batt - (c * I * V)`.
  final double batterySelfHeatCoefficient;

  /// Clamp for `(1/k) * dT_batt/dt`.
  final double maxLagCorrectionCelsius;

  /// Clamp for `c * I * V`.
  final double maxSelfHeatCorrectionCelsius;

  /// Minimum interval before `dT_batt/dt` is recomputed.
  final Duration minBatteryDerivativeDuration;

  /// Clamp for `|dT_batt/dt|` in °C/s.
  final double maxBatteryDerivativePerSecond;

  @override
  List<Object?> get props => [
    baselineStableDuration,
    baselineMinSamples,
    maxDisplayDeltaPerMinute,
    emaTimeConstant,
    historyLimit,
    maxCalibrationPoints,
    batteryCouplingKPerSecond,
    batterySelfHeatCoefficient,
    maxLagCorrectionCelsius,
    maxSelfHeatCorrectionCelsius,
    minBatteryDerivativeDuration,
    maxBatteryDerivativePerSecond,
  ];
}

/// Why a manual calibration should show a warning, if at all.
enum CalibrationCondition {
  /// Device looks idle enough to trust the point.
  good,

  /// Charging, hot, high load, or otherwise biased.
  poor,
}

/// Inspects a snapshot for calibration safety.
class CalibrationConditionChecker {
  /// Creates a checker.
  const CalibrationConditionChecker();

  /// Classifies [snapshot] for a manual calibration.
  CalibrationCondition inspect(ThermalSnapshot snapshot) {
    if (snapshot.isCharging) {
      return CalibrationCondition.poor;
    }
    final thermalStatus = snapshot.thermalStatus;
    if (thermalStatus != null && thermalStatus >= 2) {
      return CalibrationCondition.poor;
    }
    final cpu = snapshot.cpuClusterCelsius;
    final battery = snapshot.batteryCelsius;
    if (cpu != null && battery != null && cpu - battery > 25) {
      return CalibrationCondition.poor;
    }
    final cpuLoad = snapshot.cpuUsagePercent;
    if (cpuLoad != null && cpuLoad > 45) {
      return CalibrationCondition.poor;
    }
    return CalibrationCondition.good;
  }
}
