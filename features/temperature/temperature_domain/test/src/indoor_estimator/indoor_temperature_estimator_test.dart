import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  const estimator = IndoorTemperatureEstimator();

  ThermalSnapshot snap({
    required DateTime at,
    double? battery,
    bool charging = false,
    bool screenOn = true,
    int thermalStatus = 0,
    double? cpuLoad,
    double cpu = 40,
    double gpu = 38,
    double sdr0 = 27,
    double? pa1,
    double? extraAc,
    int? batteryCurrentMicroamps,
    int? batteryVoltageMillivolts,
    List<ThermalZoneReading>? zones,
  }) {
    return ThermalSnapshot(
      timestamp: at,
      isCharging: charging,
      batteryCelsius: battery,
      batteryLevelPercent: 80,
      batteryCurrentMicroamps: batteryCurrentMicroamps,
      batteryVoltageMillivolts: batteryVoltageMillivolts,
      screenOn: screenOn,
      thermalStatus: thermalStatus,
      cpuUsagePercent: cpuLoad,
      zones:
          zones ??
          [
            ThermalZoneReading(name: 'sdr0', temperatureCelsius: sdr0),
            ThermalZoneReading(name: 'cpu-0', temperatureCelsius: cpu),
            ThermalZoneReading(name: 'gpu_tmu', temperatureCelsius: gpu),
            ThermalZoneReading(name: 'pa', temperatureCelsius: cpu - 8),
            ThermalZoneReading(name: 'xo-therm', temperatureCelsius: cpu - 6),
            if (pa1 != null)
              ThermalZoneReading(name: 'pa1', temperatureCelsius: pa1),
            if (extraAc != null)
              ThermalZoneReading(name: 'ac', temperatureCelsius: extraAc),
          ],
    );
  }

  IndoorEstimateStep run(
    ThermalSnapshot snapshot, {
    IndoorEstimatorState state = IndoorEstimatorState.empty,
    IndoorCalibrationProfile profile = IndoorCalibrationProfile.empty,
  }) {
    return estimator.estimate(
      snapshot: snapshot,
      state: state,
      profile: profile,
    );
  }

  group('BatteryRoomTemperatureModel', () {
    const model = BatteryRoomTemperatureModel(
      couplingKPerSecond: 0.01,
      selfHeatCoefficient: 1,
    );

    test('steady battery with no power equals T_batt', () {
      final terms = model.evaluate(batteryCelsius: 30);
      expect(terms.roomCelsius, 30);
      expect(terms.lagCorrectionCelsius, 0);
      expect(terms.selfHeatCorrectionCelsius, 0);
    });

    test('self-heating subtracts c·I·V from T_batt', () {
      final terms = model.evaluate(
        batteryCelsius: 30,
        currentAmps: 0.5,
        voltageVolts: 4,
      );
      expect(terms.selfHeatCorrectionCelsius, 2);
      expect(terms.roomCelsius, 28);
    });

    test('cooling lag adds (1/k)·dT/dt to T_batt', () {
      final terms = model.evaluate(
        batteryCelsius: 30,
        dBatteryCelsiusPerSecond: -0.02,
      );
      expect(terms.lagCorrectionCelsius, closeTo(-2, 1e-9));
      expect(terms.roomCelsius, closeTo(28, 1e-9));
    });

    test('combined equations match T_batt + (1/k)dT/dt − cIV', () {
      final terms = model.evaluate(
        batteryCelsius: 30,
        dBatteryCelsiusPerSecond: -0.02,
        currentAmps: 0.5,
        voltageVolts: 4,
      );
      expect(terms.roomCelsius, closeTo(26, 1e-9));
    });
  });

  group('IndoorTemperatureEstimator', () {
    test('battery physics is used instead of CPU or raw internals', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 35,
          sdr0: 27,
          cpu: 48,
          gpu: 43,
        ),
      );
      final result = step.result!;
      expect(result.selectedSensors, contains('battery'));
      expect(result.temperatureCelsius, closeTo(35, 1.5));
      expect(result.temperatureCelsius, isNot(closeTo(48, 0.6)));
      expect(result.debug.networkRequired, isFalse);
      expect(result.debug.lagCorrectionCelsius, isNotNull);
    });

    test('battery much hotter than CPU is still not CPU temperature', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 42,
          sdr0: 28,
          cpu: 70,
          gpu: 55,
        ),
      );
      expect(step.result!.temperatureCelsius, closeTo(42, 1.5));
      expect(step.result!.temperatureCelsius, isNot(closeTo(70, 1)));
    });

    test('phone cooling down follows battery lag, not CPU', () {
      var state = IndoorEstimatorState.empty;
      IndoorEstimateResult? last;
      for (var i = 0; i < 6; i++) {
        final step = run(
          snap(
            at: DateTime(2026, 1, 1, 12, i * 5),
            battery: 36.8 - i * 1.2,
            sdr0: 34 - i * 1.1,
            cpu: 55 - i * 2,
            gpu: 48 - i * 1.5,
          ),
          state: state,
        );
        state = step.state;
        last = step.result;
      }
      expect(last!.temperatureCelsius, lessThan(36.8));
      expect(last.temperatureCelsius, greaterThan(20));
      expect(last.temperatureCelsius, isNot(closeTo(55, 8)));
    });

    test('phone warming up does not jump to CPU temperature', () {
      var state = IndoorEstimatorState.empty;
      final first = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 29,
          sdr0: 27,
          cpu: 40,
        ),
        state: state,
      );
      state = first.state;
      final later = run(
        snap(
          at: DateTime(2026, 1, 1, 12, 20),
          battery: 32,
          sdr0: 28,
          cpu: 62,
        ),
        state: state,
      );
      expect(later.result!.temperatureCelsius, lessThan(40));
      expect(
        (later.result!.temperatureCelsius - first.result!.temperatureCelsius)
            .abs(),
        lessThan(4),
      );
    });

    test('charging lowers confidence and does not track charger heat', () {
      final idle = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 30,
          sdr0: 27,
          cpu: 42,
        ),
      );
      final charging = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 38,
          sdr0: 29,
          cpu: 48,
          charging: true,
          batteryCurrentMicroamps: 1500000,
          batteryVoltageMillivolts: 4100,
        ),
      );
      expect(charging.result!.confidence, lessThan(idle.result!.confidence));
      expect(charging.result!.temperatureCelsius, lessThan(38));
    });

    test('discharging idle estimate uses battery physics', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 29.4,
          sdr0: 27,
          cpu: 47,
          gpu: 43,
          extraAc: 31.1,
        ),
      );
      expect(step.result!.temperatureCelsius, closeTo(29.4, 1.5));
      expect(step.result!.debug.isCharging, isFalse);
      expect(step.result!.selectedSensors, contains('battery'));
    });

    test('CPU spike does not cause a huge indoor-temperature spike', () {
      var state = IndoorEstimatorState.empty;
      final stable = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 30,
          sdr0: 27,
          cpu: 40,
        ),
        state: state,
      );
      state = stable.state;
      final spiked = run(
        snap(
          at: DateTime(2026, 1, 1, 12, 1),
          battery: 31,
          sdr0: 27.2,
          cpu: 75,
        ),
        state: state,
      );
      expect(
        (spiked.result!.temperatureCelsius - stable.result!.temperatureCelsius)
            .abs(),
        lessThan(1.5),
      );
      expect(spiked.result!.temperatureCelsius, isNot(closeTo(75, 10)));
      expect(spiked.result!.confidence, lessThan(stable.result!.confidence));
    });

    test('GPU spike is ignored like other component heat', () {
      var state = IndoorEstimatorState.empty;
      final stable = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 30,
          sdr0: 27,
          cpu: 42,
          gpu: 40,
        ),
        state: state,
      );
      state = stable.state;
      final spiked = run(
        snap(
          at: DateTime(2026, 1, 1, 12, 1),
          battery: 30.5,
          sdr0: 27.1,
          cpu: 44,
          gpu: 72,
        ),
        state: state,
      );
      expect(
        (spiked.result!.temperatureCelsius - stable.result!.temperatureCelsius)
            .abs(),
        lessThan(1.5),
      );
    });

    test('no useful thermal zones still estimates from battery only', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 33,
          zones: const [],
        ),
      );
      expect(step.result, isNotNull);
      expect(step.result!.temperatureCelsius, closeTo(33, 1.5));
      expect(step.result!.confidence, lessThan(0.45));
      expect(step.result!.selectedSensors, contains('battery'));
    });

    test('only battery available is not labelled as room truth', () {
      final step = run(
        ThermalSnapshot(
          timestamp: DateTime(2026, 1, 1, 12),
          isCharging: false,
          batteryCelsius: 36.8,
          zones: const [],
        ),
      );
      expect(step.result!.confidence, lessThan(0.45));
      expect(step.result!.isApproximate, isTrue);
    });

    test('sdr0 is still scored as an environmental proxy', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 29.4,
          sdr0: 27,
          cpu: 48,
        ),
      );
      expect(step.result!.selectedSensors, contains('battery'));
      final sdr0 = step.result!.debug.zones.firstWhere(
        (zone) => zone.name == 'sdr0',
      );
      expect(sdr0.environmentScore, greaterThan(0.4));
      expect(sdr0.classification, isNot(ThermalZoneClass.invalid));
    });

    test('sdr0 unavailable still estimates from remaining signals', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 31,
          cpu: 50,
          gpu: 44,
          zones: const [
            ThermalZoneReading(name: 'cpu-0', temperatureCelsius: 50),
            ThermalZoneReading(name: 'gpu_tmu', temperatureCelsius: 44),
            ThermalZoneReading(name: 'skin', temperatureCelsius: 28.5),
          ],
        ),
      );
      expect(step.result, isNotNull);
      expect(step.result!.selectedSensors, contains('battery'));
      expect(step.result!.temperatureCelsius, closeTo(31, 1.5));
    });

    test('pa1 abnormal stuck value is rejected', () {
      var state = IndoorEstimatorState.empty;
      IndoorEstimateStep? last;
      for (var i = 0; i < 8; i++) {
        last = run(
          snap(
            at: DateTime(2026, 1, 1, 12, i),
            battery: 29.4 + i * 0.05,
            sdr0: 27 + i * 0.04,
            cpu: 47 + i * 0.2,
            pa1: 11.3,
          ),
          state: state,
        );
        state = last.state;
      }
      final pa1 = last!.result!.debug.zones.firstWhere(
        (zone) => zone.name == 'pa1',
      );
      expect(pa1.environmentScore, 0);
      expect(pa1.rejectReason, 'suspicious/outlier');
      expect(last.result!.selectedSensors, isNot(contains('pa1')));
      expect(last.result!.temperatureCelsius, isNot(closeTo(11.3, 1)));
    });

    test('stale sensor is rejected', () {
      final step = run(
        ThermalSnapshot(
          timestamp: DateTime(2026, 1, 1, 12),
          isCharging: false,
          batteryCelsius: 30,
          zones: [
            ThermalZoneReading(
              name: 'sdr0',
              temperatureCelsius: 21,
              timestamp: DateTime(2026, 1, 1, 11, 40),
            ),
            const ThermalZoneReading(name: 'cpu-0', temperatureCelsius: 48),
          ],
        ),
      );
      final sdr0 = step.result!.debug.zones.firstWhere(
        (zone) => zone.name == 'sdr0',
      );
      expect(sdr0.rejectReason, 'stale');
    });

    test('impossible values are rejected', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 30,
          zones: const [
            ThermalZoneReading(name: 'sdr0', temperatureCelsius: 27),
            ThermalZoneReading(name: 'broken', temperatureCelsius: 180),
            ThermalZoneReading(name: 'nan', temperatureCelsius: double.nan),
            ThermalZoneReading(name: 'cpu-0', temperatureCelsius: 48),
          ],
        ),
      );
      final broken = step.result!.debug.zones.firstWhere(
        (zone) => zone.name == 'broken',
      );
      expect(broken.rejectReason, 'impossible value');
      final nan = step.result!.debug.zones.firstWhere(
        (zone) => zone.name == 'nan',
      );
      expect(nan.rejectReason, 'non-finite');
    });

    test('manual calibration shifts the estimate toward the reference', () {
      final first = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 29.4,
          sdr0: 27,
          cpu: 47,
        ),
      );
      final profile = estimator.recordManualCalibration(
        profile: IndoorCalibrationProfile.empty,
        current: first.result!,
        snapshot: snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 29.4,
          sdr0: 27,
          cpu: 47,
        ),
        actualRoomCelsius: 24,
      );
      expect(profile.hasCalibration, isTrue);
      final second = run(
        snap(
          at: DateTime(2026, 1, 1, 12, 1),
          battery: 29.4,
          sdr0: 27,
          cpu: 47,
        ),
        state: first.state,
        profile: profile,
      );
      expect(second.result!.calibrationApplied, isTrue);
      expect(second.result!.temperatureCelsius, closeTo(24, 1.2));
      expect(second.result!.confidence, greaterThan(first.result!.confidence));
    });

    test('multiple calibration points learn across environments', () {
      final coolSnap = snap(
        at: DateTime(2026, 1, 1, 12),
        battery: 29,
        sdr0: 27,
        cpu: 40,
      );
      final cool = run(coolSnap);
      var profile = estimator.recordManualCalibration(
        profile: IndoorCalibrationProfile.empty,
        current: cool.result!,
        snapshot: coolSnap,
        actualRoomCelsius: 24,
      );
      final warmSnap = snap(
        at: DateTime(2026, 1, 1, 14),
        battery: 33,
        sdr0: 31,
        cpu: 44,
      );
      final warmRaw = run(warmSnap, profile: profile);
      profile = estimator.recordManualCalibration(
        profile: profile,
        current: warmRaw.result!,
        snapshot: warmSnap,
        actualRoomCelsius: 28,
      );
      expect(profile.modelPoints, hasLength(2));
      final check = run(
        snap(
          at: DateTime(2026, 1, 1, 15),
          battery: 31,
          sdr0: 29,
          cpu: 42,
        ),
        state: warmRaw.state,
        profile: profile,
      );
      expect(check.result!.calibrationApplied, isTrue);
      expect(check.result!.temperatureCelsius, inInclusiveRange(24, 29));
    });

    test('calibration reset forgets points', () {
      final snap1 = snap(
        at: DateTime(2026, 1, 1, 12),
        battery: 29,
        sdr0: 27,
        cpu: 40,
      );
      final first = run(snap1);
      final profile = estimator.recordManualCalibration(
        profile: IndoorCalibrationProfile.empty,
        current: first.result!,
        snapshot: snap1,
        actualRoomCelsius: 24,
      );
      final reset = estimator.resetCalibration(profile);
      expect(reset.hasCalibration, isFalse);
      final after = run(snap1, profile: reset);
      expect(after.result!.calibrationApplied, isFalse);
    });

    test('automatic baseline learning locks in when idle and stable', () {
      const config = IndoorEstimatorConfig(
        baselineStableDuration: Duration(minutes: 2),
        baselineMinSamples: 3,
      );
      const local = IndoorTemperatureEstimator(config: config);
      var state = IndoorEstimatorState.empty;
      var profile = IndoorCalibrationProfile.empty;
      IndoorEstimateStep? last;
      for (var i = 0; i < 5; i++) {
        last = local.estimate(
          snapshot: snap(
            at: DateTime(2026, 1, 1, 12, i),
            battery: 29.4,
            sdr0: 27.0 + i * 0.01,
            cpu: 41,
            screenOn: false,
            cpuLoad: 8,
          ),
          state: state,
          profile: profile,
        );
        state = last.state;
        profile = last.profile;
      }
      expect(profile.baseline, isNotNull);
      expect(profile.baseline!.selectedSensors, contains('sdr0'));
      expect(profile.baseline!.isCharging, isFalse);
      expect(last!.result!.debug.statusLabel, isNotEmpty);
    });

    test('charging blocks automatic baseline learning', () {
      const config = IndoorEstimatorConfig(
        baselineStableDuration: Duration(minutes: 1),
        baselineMinSamples: 2,
      );
      const local = IndoorTemperatureEstimator(config: config);
      var state = IndoorEstimatorState.empty;
      var profile = IndoorCalibrationProfile.empty;
      for (var i = 0; i < 4; i++) {
        final step = local.estimate(
          snapshot: snap(
            at: DateTime(2026, 1, 1, 12, i),
            battery: 34,
            sdr0: 30,
            cpu: 50,
            charging: true,
            screenOn: false,
            cpuLoad: 5,
          ),
          state: state,
          profile: profile,
        );
        state = step.state;
        profile = step.profile;
      }
      expect(profile.baseline, isNull);
    });

    test('low confidence when signals are poor', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 48,
          charging: true,
          thermalStatus: 3,
          cpu: 80,
          gpu: 70,
          zones: const [
            ThermalZoneReading(name: 'cpu-0', temperatureCelsius: 80),
          ],
        ),
      );
      expect(step.result!.confidence, lessThan(0.45));
      expect(step.result!.isApproximate, isTrue);
    });

    test('network unavailable does not affect the indoor path', () {
      final step = run(
        snap(at: DateTime(2026, 1, 1, 12), battery: 29, sdr0: 27, cpu: 45),
      );
      expect(step.result!.debug.networkRequired, isFalse);
    });

    test('airplane-mode snapshot still produces an indoor estimate', () {
      final step = run(
        ThermalSnapshot(
          timestamp: DateTime(2026, 1, 1, 12),
          isCharging: false,
          batteryCelsius: 29.4,
          screenOn: true,
          thermalStatus: 0,
          zones: const [
            ThermalZoneReading(name: 'sdr0', temperatureCelsius: 27),
            ThermalZoneReading(name: 'cpu-0', temperatureCelsius: 47),
          ],
        ),
      );
      expect(step.result, isNotNull);
      expect(step.result!.debug.networkRequired, isFalse);
    });

    test('location denied is irrelevant because snapshot has no location', () {
      final step = run(
        snap(at: DateTime(2026, 1, 1, 12), battery: 29, sdr0: 27, cpu: 46),
      );
      expect(step.result, isNotNull);
    });

    test('weather API unavailability cannot enter the estimator', () {
      final json = snap(
        at: DateTime(2026, 1, 1, 12),
        battery: 29,
        sdr0: 27,
        cpu: 46,
      ).toJson();
      expect(json.containsKey('weather'), isFalse);
      expect(json.containsKey('latitude'), isFalse);
      expect(json.containsKey('url'), isFalse);
    });

    test('sudden internal thermal spike is rate-limited', () {
      var state = IndoorEstimatorState.empty;
      final stable = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 30,
          sdr0: 27,
          cpu: 41,
        ),
        state: state,
      );
      state = stable.state;
      final spike = run(
        snap(
          at: DateTime(2026, 1, 1, 12, 0, 20),
          battery: 33,
          sdr0: 40,
          cpu: 78,
        ),
        state: state,
      );
      expect(
        spike.result!.temperatureCelsius,
        closeTo(stable.result!.temperatureCelsius, 1.0),
      );
    });

    test('no sensors at all yields no estimate', () {
      final step = run(
        ThermalSnapshot(
          timestamp: DateTime(2026, 1, 1, 12),
          isCharging: false,
        ),
      );
      expect(step.result, isNull);
    });

    test('estimator applies lag and self-heat to battery temperature', () {
      const local = IndoorTemperatureEstimator(
        config: IndoorEstimatorConfig(
          batteryCouplingKPerSecond: 0.01,
          batterySelfHeatCoefficient: 1,
          minBatteryDerivativeDuration: Duration(seconds: 1),
          maxBatteryDerivativePerSecond: 0.05,
          emaTimeConstant: Duration(seconds: 1),
          maxDisplayDeltaPerMinute: 30,
        ),
      );
      final first = local.estimate(
        snapshot: snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 32,
          zones: const [],
          batteryCurrentMicroamps: 500000,
          batteryVoltageMillivolts: 4000,
        ),
      );
      expect(first.result!.temperatureCelsius, closeTo(30, 0.4));
      expect(first.result!.debug.selfHeatCorrectionCelsius, closeTo(2, 0.05));

      final second = local.estimate(
        snapshot: snap(
          at: DateTime(2026, 1, 1, 12, 1, 40),
          battery: 30,
          zones: const [],
          batteryCurrentMicroamps: 500000,
          batteryVoltageMillivolts: 4000,
        ),
        state: first.state,
      );
      expect(second.result!.temperatureCelsius, closeTo(26, 0.6));
      expect(
        second.result!.debug.lagCorrectionCelsius,
        closeTo(-2, 0.25),
      );
      expect(
        second.result!.debug.selfHeatCorrectionCelsius,
        closeTo(2, 0.05),
      );
    });

    test('supports a wide indoor range after calibration', () {
      for (final room in [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0]) {
        final rawSnap = snap(
          at: DateTime(2026, 1, 1, 12),
          battery: room + 5,
          sdr0: room + 3,
          cpu: room + 18,
        );
        final first = run(rawSnap);
        final profile = estimator.recordManualCalibration(
          profile: IndoorCalibrationProfile.empty,
          current: first.result!,
          snapshot: rawSnap,
          actualRoomCelsius: room,
        );
        final second = run(
          snap(
            at: DateTime(2026, 1, 1, 12, 1),
            battery: room + 5,
            sdr0: room + 3,
            cpu: room + 18,
          ),
          state: first.state,
          profile: profile,
        );
        expect(
          second.result!.temperatureCelsius,
          closeTo(room, 1.5),
          reason: 'room $room',
        );
      }
    });

    test('poor calibration conditions are flagged but still stored', () {
      final chargingSnap = snap(
        at: DateTime(2026, 1, 1, 12),
        battery: 38,
        sdr0: 30,
        cpu: 60,
        charging: true,
      );
      final first = run(chargingSnap);
      final profile = estimator.recordManualCalibration(
        profile: IndoorCalibrationProfile.empty,
        current: first.result!,
        snapshot: chargingSnap,
        actualRoomCelsius: 24,
      );
      expect(profile.points.single.poorConditions, isTrue);
      expect(profile.hasCalibration, isTrue);
    });
  });

  group('simulation', () {
    test('scenario A: estimate uses battery physics, not CPU', () {
      final step = run(
        snap(
          at: DateTime(2026, 1, 1, 12),
          battery: 35,
          sdr0: 27,
          cpu: 70,
          gpu: 50,
        ),
      );
      expect(step.result!.temperatureCelsius, closeTo(35, 2));
      expect(step.result!.temperatureCelsius, isNot(closeTo(70, 8)));
    });

    test('scenario B: calibrated estimate tracks the room, not internals', () {
      final firstSnap = snap(
        at: DateTime(2026, 1, 1, 12),
        battery: 29,
        sdr0: 27,
        cpu: 40,
      );
      final first = run(firstSnap);
      final profile = estimator.recordManualCalibration(
        profile: IndoorCalibrationProfile.empty,
        current: first.result!,
        snapshot: firstSnap,
        actualRoomCelsius: 24,
      );
      final second = run(
        firstSnap.copyWithTimestamp(DateTime(2026, 1, 1, 12, 2)),
        state: first.state,
        profile: profile,
      );
      expect(second.result!.temperatureCelsius, closeTo(24, 1.5));
    });
  });

  group('ThermalZoneClassifier', () {
    const classifier = ThermalZoneClassifier();

    test('classifies known component and environmental names', () {
      expect(
        classifier.classifyName('sdr0'),
        ThermalZoneClass.environmental,
      );
      expect(classifier.classifyName('skin'), ThermalZoneClass.environmental);
      expect(classifier.classifyName('cpu-0'), ThermalZoneClass.component);
      expect(classifier.classifyName('gpu_tmu'), ThermalZoneClass.component);
      expect(classifier.classifyName('pa1'), ThermalZoneClass.component);
      expect(classifier.classifyName('pm6450_tz'), ThermalZoneClass.component);
      expect(classifier.classifyName('xo-therm'), ThermalZoneClass.component);
      expect(classifier.classifyName('mystery_tz'), ThermalZoneClass.candidate);
    });
  });

  group('CalibrationConditionChecker', () {
    const checker = CalibrationConditionChecker();

    test('marks charging as poor', () {
      expect(
        checker.inspect(
          snap(at: DateTime(2026), battery: 30, charging: true),
        ),
        CalibrationCondition.poor,
      );
    });

    test('marks idle discharging as good', () {
      expect(
        checker.inspect(
          snap(at: DateTime(2026), battery: 29, cpu: 40, cpuLoad: 10),
        ),
        CalibrationCondition.good,
      );
    });
  });
}

extension on ThermalSnapshot {
  ThermalSnapshot copyWithTimestamp(DateTime timestamp) {
    return ThermalSnapshot(
      timestamp: timestamp,
      isCharging: isCharging,
      batteryCelsius: batteryCelsius,
      batteryLevelPercent: batteryLevelPercent,
      batteryCurrentMicroamps: batteryCurrentMicroamps,
      batteryVoltageMillivolts: batteryVoltageMillivolts,
      screenOn: screenOn,
      thermalStatus: thermalStatus,
      cpuUsagePercent: cpuUsagePercent,
      uptime: uptime,
      zones: zones,
    );
  }
}
