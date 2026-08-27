import 'dart:math' as math;

import 'package:temperature_domain/src/indoor_estimator/battery_room_temperature.dart';
import 'package:temperature_domain/src/indoor_estimator/indoor_estimator_models.dart';
import 'package:temperature_domain/src/indoor_estimator/thermal_snapshot.dart';
import 'package:temperature_domain/src/indoor_estimator/thermal_zone_classifier.dart';

/// Local, deterministic indoor-temperature estimator.
///
/// Uses only [ThermalSnapshot] signals. Never reads weather, location, or
/// the network. When battery temperature is available, room temperature is
/// computed from
/// `T_room = T_batt + (1/k) * dT_batt/dt - (c * I * V)`.
class IndoorTemperatureEstimator {
  /// Creates an estimator.
  const IndoorTemperatureEstimator({
    this.config = IndoorEstimatorConfig.standard,
    this.classifier = const ThermalZoneClassifier(),
  });

  /// Production / test knobs.
  final IndoorEstimatorConfig config;

  /// Name-based classifier.
  final ThermalZoneClassifier classifier;

  static const double _minValidZoneCelsius = -30;
  static const double _maxValidZoneCelsius = 95;
  static const double _minPlausibleRoomCelsius = -10;
  static const double _maxPlausibleRoomCelsius = 50;
  static const double _changeEpsilonCelsius = 0.08;

  /// Runs one estimate step from [snapshot], previous [state], and [profile].
  ///
  /// [IndoorEstimateStep.result] is `null` only when the snapshot has no
  /// usable thermal signal at all.
  IndoorEstimateStep estimate({
    required ThermalSnapshot snapshot,
    IndoorEstimatorState state = IndoorEstimatorState.empty,
    IndoorCalibrationProfile profile = IndoorCalibrationProfile.empty,
  }) {
    final histories = _updateHistories(state.zoneHistories, snapshot);
    final scored = _scoreZones(snapshot, histories);
    final selected = [
      for (final zone in scored)
        if (zone.isSelectable) zone,
    ]..sort((a, b) => b.environmentScore.compareTo(a.environmentScore));

    final top = selected.take(3).toList();
    final derivative = snapshot.batteryCelsius == null
        ? state.smoothedBatteryDerivativePerSecond
        : batteryTemperatureDerivativePerSecond(
            batteryCelsius: snapshot.batteryCelsius!,
            at: snapshot.timestamp,
            previousBatteryCelsius: state.lastBatteryCelsius,
            previousAt: state.lastBatterySampledAt,
            minSampleDuration: config.minBatteryDerivativeDuration,
            maxAbsPerSecond: config.maxBatteryDerivativePerSecond,
            previousSmoothed: state.smoothedBatteryDerivativePerSecond,
          );
    final physics = _batteryPhysics(
      snapshot: snapshot,
      derivativePerSecond: derivative ?? 0,
    );
    final raw = physics?.roomCelsius ??
        _zoneRawEstimate(snapshot: snapshot, selected: top);
    if (raw == null) {
      return IndoorEstimateStep(
        state: state.copyWith(zoneHistories: histories),
        profile: profile,
      );
    }

    final cpu = snapshot.cpuClusterCelsius;
    final cpuSpiked = _cpuSpiked(
      previous: state.lastCpuCelsius,
      current: cpu,
    );
    final calibrated = _applyCalibration(
      raw: raw,
      snapshot: snapshot,
      profile: profile,
      cpuSpiked: cpuSpiked,
    );
    final smoothed = _smooth(
      incoming: calibrated.temperature,
      previous: state,
      now: snapshot.timestamp,
      cpuSpiked: cpuSpiked,
      proxyDelta: _proxyDelta(
        previous: state.lastSelectedProxyCelsius,
        current: raw,
      ),
    );
    final bounded = _boundToPlausible(smoothed);
    final confidence = _confidence(
      snapshot: snapshot,
      selected: top,
      scored: scored,
      profile: profile,
      cpuSpiked: cpuSpiked,
    );
    final nextProfile = _maybeLearnBaseline(
      snapshot: snapshot,
      state: state,
      profile: profile,
      selected: top,
      histories: histories,
    );
    final nextState = IndoorEstimatorState(
      emaCelsius: bounded,
      lastEmittedAt: snapshot.timestamp,
      idleStableSince: _nextIdleSince(
        snapshot: snapshot,
        state: state,
        selected: top,
      ),
      zoneHistories: histories,
      lastCpuCelsius: cpu,
      lastSelectedProxyCelsius: raw,
      lastBatteryCelsius:
          snapshot.batteryCelsius ?? state.lastBatteryCelsius,
      lastBatterySampledAt: snapshot.batteryCelsius != null
          ? snapshot.timestamp
          : state.lastBatterySampledAt,
      smoothedBatteryDerivativePerSecond: snapshot.batteryCelsius != null
          ? derivative
          : state.smoothedBatteryDerivativePerSecond,
    );
    final offset = bounded - raw;
    final selectedSensors = physics != null
        ? const ['battery']
        : [for (final zone in top) zone.name];
    final result = IndoorEstimateResult(
      temperatureCelsius: bounded,
      confidence: confidence,
      selectedSensors: selectedSensors,
      calibrationApplied: calibrated.applied,
      debug: IndoorEstimateDebug(
        batteryCelsius: snapshot.batteryCelsius,
        isCharging: snapshot.isCharging,
        thermalStatus: snapshot.thermalStatus,
        zones: scored,
        selectedSensors: selectedSensors,
        rawEstimateCelsius: raw,
        finalEstimateCelsius: bounded,
        confidence: confidence,
        calibrationApplied: calibrated.applied,
        calibrationOffsetCelsius: calibrated.applied ? offset : null,
        baselineQuality: profile.baseline?.stability ?? 0,
        networkRequired: false,
        cpuCelsius: cpu,
        gpuCelsius: snapshot.gpuCelsius,
        screenOn: snapshot.screenOn,
        cpuUsagePercent: snapshot.cpuUsagePercent,
        statusLabel: _statusLabel(
          confidence: confidence,
          hasCalibration: profile.hasCalibration,
          hasBaseline: nextProfile.baseline != null,
        ),
        batteryDerivativePerSecond:
            physics?.dBatteryCelsiusPerSecond,
        lagCorrectionCelsius: physics?.lagCorrectionCelsius,
        selfHeatCorrectionCelsius: physics?.selfHeatCorrectionCelsius,
        batteryCurrentAmps: physics?.currentAmps,
        batteryVoltageVolts: physics?.voltageVolts,
      ),
    );
    return IndoorEstimateStep(
      result: result,
      state: nextState,
      profile: nextProfile,
    );
  }

  /// Records a manual calibration against [actualRoomCelsius].
  IndoorCalibrationProfile recordManualCalibration({
    required IndoorCalibrationProfile profile,
    required IndoorEstimateResult current,
    required ThermalSnapshot snapshot,
    required double actualRoomCelsius,
  }) {
    if (!_isFinite(actualRoomCelsius) ||
        actualRoomCelsius < _minPlausibleRoomCelsius ||
        actualRoomCelsius > _maxPlausibleRoomCelsius) {
      return profile;
    }
    final poor =
        const CalibrationConditionChecker().inspect(snapshot) ==
        CalibrationCondition.poor;
    final raw = current.debug.rawEstimateCelsius ?? current.temperatureCelsius;
    final point = IndoorCalibrationPoint(
      timestamp: snapshot.timestamp,
      rawEstimateCelsius: raw,
      actualRoomCelsius: actualRoomCelsius,
      batteryCelsius: snapshot.batteryCelsius,
      cpuCelsius: snapshot.cpuClusterCelsius,
      selectedSensors: current.selectedSensors,
      sensorValues: {
        for (final zone in snapshot.zones)
          if (_isFinite(zone.temperatureCelsius))
            zone.name: zone.temperatureCelsius,
        if (snapshot.batteryCelsius != null)
          'battery': snapshot.batteryCelsius!,
      },
      isCharging: snapshot.isCharging,
      thermalStatus: snapshot.thermalStatus,
      confidence: current.confidence,
      usedForModel: true,
      poorConditions: poor,
    );
    final points = [...profile.points, point];
    final trimmed = points.length > config.maxCalibrationPoints
        ? points.sublist(points.length - config.maxCalibrationPoints)
        : points;
    return profile.copyWith(points: trimmed);
  }

  /// Drops all calibration points. Keeps the idle baseline.
  IndoorCalibrationProfile resetCalibration(
    IndoorCalibrationProfile profile,
  ) {
    return IndoorCalibrationProfile(baseline: profile.baseline);
  }

  Map<String, ZoneHistory> _updateHistories(
    Map<String, ZoneHistory> previous,
    ThermalSnapshot snapshot,
  ) {
    final next = Map<String, ZoneHistory>.from(previous);
    void observe(String name, double value) {
      if (!_isFinite(value)) {
        return;
      }
      final existing = next[name];
      final samples = [...?existing?.samples, value];
      final trimmed = samples.length > config.historyLimit
          ? samples.sublist(samples.length - config.historyLimit)
          : samples;
      final changed =
          existing == null ||
          (value - existing.lastValue).abs() >= _changeEpsilonCelsius;
      next[name] = ZoneHistory(
        samples: trimmed,
        lastChangedAt: changed ? snapshot.timestamp : existing.lastChangedAt,
        lastValue: value,
      );
    }

    for (final zone in snapshot.zones) {
      observe(zone.name, zone.temperatureCelsius);
    }
    if (snapshot.batteryCelsius != null) {
      observe('battery', snapshot.batteryCelsius!);
    }
    return next;
  }

  List<ScoredThermalZone> _scoreZones(
    ThermalSnapshot snapshot,
    Map<String, ZoneHistory> histories,
  ) {
    final cpuSamples = _cpuSamples(snapshot, histories);
    final validTemps = [
      for (final zone in snapshot.zones)
        if (_isFinite(zone.temperatureCelsius) &&
            zone.temperatureCelsius >= _minValidZoneCelsius &&
            zone.temperatureCelsius <= _maxValidZoneCelsius)
          zone.temperatureCelsius,
    ];
    final clusterMedian = _median(validTemps);
    return [
      for (final zone in snapshot.zones)
        _scoreOne(
          name: zone.name,
          temperature: zone.temperatureCelsius,
          timestamp: zone.timestamp,
          now: snapshot.timestamp,
          history: histories[zone.name],
          cpuSamples: cpuSamples,
          clusterMedian: clusterMedian,
          snapshot: snapshot,
        ),
    ];
  }

  ScoredThermalZone _scoreOne({
    required String name,
    required double temperature,
    required DateTime now,
    required ThermalSnapshot snapshot,
    DateTime? timestamp,
    ZoneHistory? history,
    List<double>? cpuSamples,
    double? clusterMedian,
  }) {
    if (!_isFinite(temperature)) {
      return _rejected(
        name: name,
        temperature: temperature,
        reason: 'non-finite',
      );
    }
    if (temperature < _minValidZoneCelsius ||
        temperature > _maxValidZoneCelsius) {
      return _rejected(
        name: name,
        temperature: temperature,
        reason: 'impossible value',
      );
    }

    var classification = classifier.classifyName(name);
    final samples = history?.samples ?? [temperature];
    final variance = _variance(samples);
    final range = _range(samples);

    if (timestamp != null && now.difference(timestamp).inMinutes >= 10) {
      return _rejected(
        name: name,
        temperature: temperature,
        reason: 'stale',
      );
    }

    if (samples.length >= 6 &&
        range <= 0.15 &&
        clusterMedian != null &&
        (temperature - clusterMedian).abs() >= 10) {
      return _rejected(
        name: name,
        temperature: temperature,
        reason: 'suspicious/outlier',
      );
    }

    if (temperature <= 0.05 && clusterMedian != null && clusterMedian >= 15) {
      return _rejected(
        name: name,
        temperature: temperature,
        reason: 'suspicious/outlier',
      );
    }

    final nameScore = switch (classification) {
      ThermalZoneClass.environmental => 0.92,
      ThermalZoneClass.candidate => 0.55,
      ThermalZoneClass.component => 0.08,
      ThermalZoneClass.invalid => 0.0,
    };
    final plausibilityScore = _plausibility(temperature);
    final stabilityScore = 1 / (1 + variance * 4);
    final cpuCorr = _pearson(samples, cpuSamples);
    final lowCpuCorrelationScore = cpuCorr == null
        ? 0.55
        : (1 - cpuCorr.abs()).clamp(0.0, 1.0);
    final cpu = snapshot.cpuClusterCelsius;
    final distanceFromCpu = cpu == null
        ? 0.5
        : ((cpu - temperature) / 25).clamp(0.0, 1.0);
    final heatingCoolingScore = _heatingCoolingScore(
      samples: samples,
      cpuSamples: cpuSamples,
    );
    final agreement = clusterMedian == null
        ? 0.5
        : (1 - ((temperature - clusterMedian).abs() / 18)).clamp(0.0, 1.0);
    final coolerThanBattery = snapshot.batteryCelsius == null
        ? 0.5
        : (snapshot.batteryCelsius! - temperature + 4).clamp(0.0, 8.0) / 8;

    if (classification == ThermalZoneClass.candidate &&
        lowCpuCorrelationScore >= 0.7 &&
        distanceFromCpu >= 0.45 &&
        plausibilityScore >= 0.55 &&
        stabilityScore >= 0.45) {
      classification = ThermalZoneClass.environmental;
    }

    final environmentScore =
        (nameScore * 0.22 +
                plausibilityScore * 0.18 +
                stabilityScore * 0.16 +
                lowCpuCorrelationScore * 0.18 +
                heatingCoolingScore * 0.1 +
                distanceFromCpu * 0.08 +
                agreement * 0.04 +
                coolerThanBattery * 0.04)
            .clamp(0.0, 1.0);

    if (classification == ThermalZoneClass.component) {
      return ScoredThermalZone(
        name: name,
        temperatureCelsius: temperature,
        classification: classification,
        environmentScore: environmentScore * 0.25,
        nameScore: nameScore,
        plausibilityScore: plausibilityScore,
        stabilityScore: stabilityScore,
        lowCpuCorrelationScore: lowCpuCorrelationScore,
        heatingCoolingScore: heatingCoolingScore,
        historicalReliabilityScore: agreement,
        rejectReason: 'component',
      );
    }

    return ScoredThermalZone(
      name: name,
      temperatureCelsius: temperature,
      classification: classification,
      environmentScore: environmentScore,
      nameScore: nameScore,
      plausibilityScore: plausibilityScore,
      stabilityScore: stabilityScore,
      lowCpuCorrelationScore: lowCpuCorrelationScore,
      heatingCoolingScore: heatingCoolingScore,
      historicalReliabilityScore: agreement,
    );
  }

  ScoredThermalZone _rejected({
    required String name,
    required double temperature,
    required String reason,
  }) {
    return ScoredThermalZone(
      name: name,
      temperatureCelsius: temperature,
      classification: ThermalZoneClass.invalid,
      environmentScore: 0,
      nameScore: 0,
      plausibilityScore: 0,
      stabilityScore: 0,
      lowCpuCorrelationScore: 0,
      heatingCoolingScore: 0,
      historicalReliabilityScore: 0,
      rejectReason: reason,
    );
  }

  double? _zoneRawEstimate({
    required ThermalSnapshot snapshot,
    required List<ScoredThermalZone> selected,
  }) {
    if (selected.isNotEmpty) {
      return _weightedMedian([
        for (final zone in selected)
          (value: zone.temperatureCelsius, weight: zone.environmentScore),
      ]);
    }

    final usable = [
      for (final zone in snapshot.zones)
        if (_isFinite(zone.temperatureCelsius) &&
            zone.temperatureCelsius >= 5 &&
            zone.temperatureCelsius <= 45 &&
            classifier.classifyName(zone.name) != ThermalZoneClass.component)
          zone.temperatureCelsius,
    ];
    if (usable.isNotEmpty) {
      usable.sort();
      return usable.first;
    }
    return null;
  }

  BatteryRoomTemperatureTerms? _batteryPhysics({
    required ThermalSnapshot snapshot,
    required double derivativePerSecond,
  }) {
    final battery = snapshot.batteryCelsius;
    if (battery == null ||
        !_isFinite(battery) ||
        battery < _minValidZoneCelsius ||
        battery > _maxValidZoneCelsius) {
      return null;
    }
    final currentMicroamps = snapshot.batteryCurrentMicroamps;
    final voltageMillivolts = snapshot.batteryVoltageMillivolts;
    final currentAmps =
        currentMicroamps == null ? 0.0 : currentMicroamps.abs() / 1e6;
    final voltageVolts =
        voltageMillivolts == null || voltageMillivolts <= 0
        ? 0.0
        : voltageMillivolts / 1000.0;
    return BatteryRoomTemperatureModel(
      couplingKPerSecond: config.batteryCouplingKPerSecond,
      selfHeatCoefficient: config.batterySelfHeatCoefficient,
      maxLagCorrectionCelsius: config.maxLagCorrectionCelsius,
      maxSelfHeatCorrectionCelsius: config.maxSelfHeatCorrectionCelsius,
    ).evaluate(
      batteryCelsius: battery,
      dBatteryCelsiusPerSecond: derivativePerSecond,
      currentAmps: currentAmps,
      voltageVolts: voltageVolts,
    );
  }

  ({double temperature, bool applied}) _applyCalibration({
    required double raw,
    required ThermalSnapshot snapshot,
    required IndoorCalibrationProfile profile,
    required bool cpuSpiked,
  }) {
    final points = profile.modelPoints;
    if (points.isEmpty) {
      return (temperature: raw, applied: false);
    }

    final xs = [for (final point in points) point.rawEstimateCelsius];
    final ys = [for (final point in points) point.actualRoomCelsius];
    if (points.length >= 2) {
      final model = _ols(xs, ys);
      if (model != null) {
        final slope = model.slope.clamp(0.4, 1.6);
        final mapped = slope * raw + model.intercept;
        return (
          temperature: _dampenDeviceHeat(
            mapped: mapped,
            raw: raw,
            snapshot: snapshot,
            lastPoint: points.last,
            cpuSpiked: cpuSpiked,
          ),
          applied: true,
        );
      }
    }

    final last = points.last;
    final estimate = last.actualRoomCelsius + (raw - last.rawEstimateCelsius);
    return (
      temperature: _dampenDeviceHeat(
        mapped: estimate,
        raw: raw,
        snapshot: snapshot,
        lastPoint: last,
        cpuSpiked: cpuSpiked,
      ),
      applied: true,
    );
  }

  double _dampenDeviceHeat({
    required double mapped,
    required double raw,
    required ThermalSnapshot snapshot,
    required IndoorCalibrationPoint lastPoint,
    required bool cpuSpiked,
  }) {
    final proxyRise = raw - lastPoint.rawEstimateCelsius;
    final deviceHotter =
        snapshot.isCharging ||
        cpuSpiked ||
        (snapshot.thermalStatus != null && snapshot.thermalStatus! >= 2) ||
        _batteryMuchHotter(snapshot.batteryCelsius, lastPoint.batteryCelsius);
    if (deviceHotter && proxyRise > 0) {
      final damped = lastPoint.actualRoomCelsius + proxyRise * 0.15;
      return math.min(mapped, damped);
    }
    return mapped;
  }

  bool _batteryMuchHotter(double? now, double? then) {
    if (now == null || then == null) {
      return false;
    }
    return now - then >= 6;
  }

  double _smooth({
    required double incoming,
    required IndoorEstimatorState previous,
    required DateTime now,
    required bool cpuSpiked,
    required double proxyDelta,
  }) {
    final last = previous.emaCelsius;
    final lastAt = previous.lastEmittedAt;
    if (last == null || lastAt == null) {
      return incoming;
    }
    final proxyUnchanged = proxyDelta.abs() < 0.5;
    if (proxyUnchanged && (incoming - last).abs() > 1) {
      return incoming;
    }
    final dt = now.difference(lastAt);
    if (dt.isNegative || dt.inMilliseconds == 0) {
      return last;
    }
    if (cpuSpiked && proxyDelta.abs() < 1.0) {
      return last;
    }
    final tauSeconds = config.emaTimeConstant.inMilliseconds / 1000;
    final dtSeconds = math.max(dt.inMilliseconds / 1000, 0.001);
    final alpha = 1 - math.exp(-dtSeconds / tauSeconds);
    final ema = last + (incoming - last) * alpha.clamp(0.02, 1.0);
    final maxDelta = config.maxDisplayDeltaPerMinute * (dtSeconds / 60);
    final delta = (ema - last).clamp(-maxDelta, maxDelta);
    return last + delta;
  }

  double _boundToPlausible(double value) {
    if (!_isFinite(value)) {
      return _minPlausibleRoomCelsius;
    }
    return value.clamp(_minPlausibleRoomCelsius, _maxPlausibleRoomCelsius);
  }

  double _confidence({
    required ThermalSnapshot snapshot,
    required List<ScoredThermalZone> selected,
    required List<ScoredThermalZone> scored,
    required IndoorCalibrationProfile profile,
    required bool cpuSpiked,
  }) {
    var score = 0.22;
    score += 0.16 * (selected.length / 3).clamp(0.0, 1.0);
    if (selected.length >= 2) {
      final temps = [for (final zone in selected) zone.temperatureCelsius];
      final spread = _range(temps);
      score += 0.12 * (1 - (spread / 8).clamp(0.0, 1.0));
    } else {
      score -= 0.04;
    }
    if (profile.hasCalibration) {
      score += 0.22;
    }
    if (profile.baseline != null) {
      score += 0.06 * profile.baseline!.stability.clamp(0.0, 1.0);
    }
    final onlyBattery = selected.isEmpty && snapshot.batteryCelsius != null;
    if (onlyBattery) {
      score -= 0.18;
    }
    if (snapshot.isCharging) {
      score -= 0.14;
    }
    if (snapshot.thermalStatus != null && snapshot.thermalStatus! >= 2) {
      score -= 0.16;
    }
    if (cpuSpiked) {
      score -= 0.1;
    }
    final raw = selected.isEmpty
        ? snapshot.batteryCelsius
        : selected.first.temperatureCelsius;
    if (raw != null && (raw < 0 || raw > 40) && !profile.hasCalibration) {
      score -= 0.12;
    }
    final reliable = [
      for (final zone in scored)
        if (zone.rejectReason == null) zone,
    ];
    if (reliable.isEmpty) {
      score -= 0.1;
    }
    return score.clamp(0.05, 0.97);
  }

  IndoorCalibrationProfile _maybeLearnBaseline({
    required ThermalSnapshot snapshot,
    required IndoorEstimatorState state,
    required IndoorCalibrationProfile profile,
    required List<ScoredThermalZone> selected,
    required Map<String, ZoneHistory> histories,
  }) {
    if (!_isIdle(snapshot) || selected.isEmpty) {
      return profile;
    }
    final idleSince = state.idleStableSince;
    if (idleSince == null) {
      return profile;
    }
    if (snapshot.timestamp.difference(idleSince) <
        config.baselineStableDuration) {
      return profile;
    }
    final proxyHistory = histories[selected.first.name];
    if (proxyHistory == null ||
        proxyHistory.samples.length < config.baselineMinSamples) {
      return profile;
    }
    if (_variance(proxyHistory.samples) > 0.35) {
      return profile;
    }
    final baseline = IndoorBaseline(
      timestamp: snapshot.timestamp,
      selectedSensors: [for (final zone in selected) zone.name],
      sensorValues: {
        for (final zone in selected) zone.name: zone.temperatureCelsius,
        if (snapshot.batteryCelsius != null)
          'battery': snapshot.batteryCelsius!,
      },
      batteryCelsius: snapshot.batteryCelsius,
      stability: (1 / (1 + _variance(proxyHistory.samples) * 6)).clamp(
        0.0,
        1.0,
      ),
      isCharging: false,
    );
    return profile.copyWith(baseline: baseline);
  }

  DateTime? _nextIdleSince({
    required ThermalSnapshot snapshot,
    required IndoorEstimatorState state,
    required List<ScoredThermalZone> selected,
  }) {
    if (!_isIdle(snapshot) || selected.isEmpty) {
      return null;
    }
    return state.idleStableSince ?? snapshot.timestamp;
  }

  bool _isIdle(ThermalSnapshot snapshot) {
    if (snapshot.isCharging) {
      return false;
    }
    if (snapshot.screenOn ?? true) {
      return false;
    }
    if (snapshot.thermalStatus != null && snapshot.thermalStatus! >= 2) {
      return false;
    }
    if (snapshot.cpuUsagePercent != null && snapshot.cpuUsagePercent! > 18) {
      return false;
    }
    return true;
  }

  bool _cpuSpiked({required double? previous, required double? current}) {
    if (previous == null || current == null) {
      return false;
    }
    return current - previous >= 8;
  }

  double _proxyDelta({required double? previous, required double? current}) {
    if (previous == null || current == null) {
      return 0;
    }
    return current - previous;
  }

  String _statusLabel({
    required double confidence,
    required bool hasCalibration,
    required bool hasBaseline,
  }) {
    if (confidence < 0.45) {
      return 'Low confidence';
    }
    if (hasCalibration) {
      return 'Calibrated';
    }
    if (hasBaseline) {
      return 'Learning baseline';
    }
    return 'Learning baseline';
  }

  List<double>? _cpuSamples(
    ThermalSnapshot snapshot,
    Map<String, ZoneHistory> histories,
  ) {
    for (final entry in histories.entries) {
      if (ThermalZoneClassifier.isCpuName(entry.key)) {
        return entry.value.samples;
      }
    }
    final cpu = snapshot.cpuClusterCelsius;
    if (cpu == null) {
      return null;
    }
    return [cpu];
  }

  double _plausibility(double temperature) {
    if (temperature < 0 || temperature > 48) {
      return 0.1;
    }
    if (temperature >= 12 && temperature <= 38) {
      return 0.95;
    }
    if (temperature >= 5 && temperature <= 42) {
      return 0.7;
    }
    return 0.35;
  }

  double _heatingCoolingScore({
    required List<double> samples,
    required List<double>? cpuSamples,
  }) {
    if (samples.length < 4) {
      return 0.5;
    }
    final ownSlope = samples.last - samples.first;
    if (cpuSamples == null || cpuSamples.length < 4) {
      return ownSlope.abs() < 6 ? 0.7 : 0.4;
    }
    final cpuSlope = cpuSamples.last - cpuSamples.first;
    if (cpuSlope > 8 && ownSlope < 2) {
      return 0.9;
    }
    if (cpuSlope > 8 && ownSlope > 8) {
      return 0.15;
    }
    return 0.55;
  }
}

bool _isFinite(double value) => value.isFinite;

double _variance(List<double> samples) {
  if (samples.length < 2) {
    return 0;
  }
  final mean = samples.reduce((a, b) => a + b) / samples.length;
  var sum = 0.0;
  for (final sample in samples) {
    final d = sample - mean;
    sum += d * d;
  }
  return sum / (samples.length - 1);
}

double _range(List<double> samples) {
  if (samples.isEmpty) {
    return 0;
  }
  var min = samples.first;
  var max = samples.first;
  for (final sample in samples) {
    if (sample < min) {
      min = sample;
    }
    if (sample > max) {
      max = sample;
    }
  }
  return max - min;
}

double? _median(List<double> samples) {
  if (samples.isEmpty) {
    return null;
  }
  final sorted = [...samples]..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) {
    return sorted[mid];
  }
  return (sorted[mid - 1] + sorted[mid]) / 2;
}

double _weightedMedian(List<({double value, double weight})> items) {
  if (items.isEmpty) {
    return 0;
  }
  final sorted = [...items]..sort((a, b) => a.value.compareTo(b.value));
  final total = sorted.fold<double>(0, (sum, item) => sum + item.weight);
  if (total <= 0) {
    return sorted[sorted.length ~/ 2].value;
  }
  var cumulative = 0.0;
  for (final item in sorted) {
    cumulative += item.weight;
    if (cumulative >= total / 2) {
      return item.value;
    }
  }
  return sorted.last.value;
}

double? _pearson(List<double>? x, List<double>? y) {
  if (x == null || y == null) {
    return null;
  }
  final n = math.min(x.length, y.length);
  if (n < 5) {
    return null;
  }
  final xs = x.sublist(x.length - n);
  final ys = y.sublist(y.length - n);
  final meanX = xs.reduce((a, b) => a + b) / n;
  final meanY = ys.reduce((a, b) => a + b) / n;
  var num = 0.0;
  var denX = 0.0;
  var denY = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = xs[i] - meanX;
    final dy = ys[i] - meanY;
    num += dx * dy;
    denX += dx * dx;
    denY += dy * dy;
  }
  if (denX <= 0 || denY <= 0) {
    return null;
  }
  return num / math.sqrt(denX * denY);
}

({double slope, double intercept})? _ols(List<double> x, List<double> y) {
  if (x.length != y.length || x.length < 2) {
    return null;
  }
  final n = x.length;
  final meanX = x.reduce((a, b) => a + b) / n;
  final meanY = y.reduce((a, b) => a + b) / n;
  var num = 0.0;
  var den = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = x[i] - meanX;
    num += dx * (y[i] - meanY);
    den += dx * dx;
  }
  if (den.abs() < 1e-6) {
    return (slope: 1, intercept: meanY - meanX);
  }
  final slope = num / den;
  return (slope: slope, intercept: meanY - slope * meanX);
}
