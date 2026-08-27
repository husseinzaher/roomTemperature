import 'package:room_temperature_app/services/ambient_sensor_service.dart';
import 'package:room_temperature_app/services/battery_temperature_service.dart';
import 'package:room_temperature_app/services/indoor_estimator_store.dart';
import 'package:room_temperature_app/services/thermal_data_service.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// Common abstraction for indoor-temperature providers.
///
/// The UI must not contain sensor-selection logic — [IndoorTemperatureService]
/// is the only place that chooses among these providers.
abstract interface class IndoorTemperatureProvider {
  /// Whether this provider can currently produce readings.
  Future<bool> isAvailable();

  /// Emits Celsius readings from this source.
  Stream<double> get temperatureStream;

  /// The concrete source represented by this provider.
  IndoorTemperatureSource get source;
}

Stream<double> _oneShotStream(Future<double?> Function() read) async* {
  final value = await read();
  if (value != null) {
    yield value;
  }
}

/// Android ambient temperature provider (`Sensor.TYPE_AMBIENT_TEMPERATURE`).
class AndroidAmbientTemperatureProvider implements IndoorTemperatureProvider {
  /// Creates an Android ambient temperature provider.
  const AndroidAmbientTemperatureProvider(this._service);

  final AmbientSensorService _service;

  @override
  IndoorTemperatureSource get source => IndoorTemperatureSource.ambientSensor;

  @override
  Future<bool> isAvailable() => _service.isAvailable();

  @override
  Stream<double> get temperatureStream => _oneShotStream(_service.readCelsius);
}

/// Placeholder for a future BLE temperature sensor provider.
class BluetoothTemperatureProvider implements IndoorTemperatureProvider {
  /// Creates a Bluetooth temperature provider.
  const BluetoothTemperatureProvider();

  @override
  IndoorTemperatureSource get source => IndoorTemperatureSource.bluetoothSensor;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Stream<double> get temperatureStream => const Stream.empty();
}

/// Phone battery temperature provider.
///
/// This is a device measurement, not an actual room-temperature reading.
class BatteryTemperatureProvider implements IndoorTemperatureProvider {
  /// Creates a battery temperature provider.
  const BatteryTemperatureProvider(this._service);

  final BatteryTemperatureService _service;

  @override
  IndoorTemperatureSource get source =>
      IndoorTemperatureSource.batteryTemperature;

  @override
  Future<bool> isAvailable() => _service.isAvailable();

  @override
  Stream<double> get temperatureStream => _oneShotStream(_service.readCelsius);
}

/// User-entered indoor temperature provider.
class ManualTemperatureProvider implements IndoorTemperatureProvider {
  /// Creates a manual temperature provider.
  const ManualTemperatureProvider(this._readManualCelsius);

  final double? Function() _readManualCelsius;

  @override
  IndoorTemperatureSource get source => IndoorTemperatureSource.manual;

  @override
  Future<bool> isAvailable() async => _readManualCelsius() != null;

  @override
  Stream<double> get temperatureStream =>
      _oneShotStream(() async => _readManualCelsius());
}

/// Local offline thermal-estimator provider. Never uses weather or GPS.
class ThermalEstimateProvider implements IndoorTemperatureProvider {
  /// Creates a thermal-estimate provider.
  ThermalEstimateProvider({
    required ThermalDataService thermalData,
    required this.store,
    this.estimator = const IndoorTemperatureEstimator(),
  }) : _thermalData = thermalData;

  final ThermalDataService _thermalData;
  final IndoorEstimatorStore store;
  final IndoorTemperatureEstimator estimator;

  /// Last estimator result from this provider.
  IndoorEstimateResult? lastResult;

  /// Last thermal snapshot read from the device.
  ThermalSnapshot? lastSnapshot;

  @override
  IndoorTemperatureSource get source => IndoorTemperatureSource.estimated;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Stream<double> get temperatureStream async* {
    final reading = await read();
    if (reading != null) {
      yield reading.celsius;
    }
  }

  /// Runs one local estimate and persists estimator state.
  Future<IndoorTemperatureReading?> read() async {
    final snapshot = await _thermalData.readSnapshot();
    lastSnapshot = snapshot;
    if (snapshot == null) {
      lastResult = null;
      return null;
    }
    final state = await store.loadState();
    final profile = await store.loadProfile();
    final step = estimator.estimate(
      snapshot: snapshot,
      state: state,
      profile: profile,
    );
    await store.saveState(step.state);
    if (step.profile != profile) {
      await store.saveProfile(step.profile);
    }
    lastResult = step.result;
    final result = step.result;
    if (result == null) {
      return null;
    }
    return IndoorTemperatureReading(
      celsius: result.displayCelsius,
      source: IndoorTemperatureSource.estimated,
      confidence: result.confidence,
      calibrationApplied: result.calibrationApplied,
      debug: result.debug,
    );
  }
}

/// Resolves the active indoor-temperature source from user settings.
///
/// Automatic priority (all local, no network):
/// 1. Android ambient temperature sensor
/// 2. Bluetooth BLE temperature sensor
/// 3. Local thermal estimate
/// 4. Manual temperature
///
/// Battery temperature is never chosen automatically as room temperature.
class IndoorTemperatureService {
  /// Creates an indoor-temperature service.
  IndoorTemperatureService({
    required IndoorTemperatureProvider ambientProvider,
    required IndoorTemperatureProvider bluetoothProvider,
    required IndoorTemperatureProvider batteryProvider,
    required IndoorTemperatureProvider manualProvider,
    required IndoorTemperatureProvider thermalProvider,
  }) : _ambientProvider = ambientProvider,
       _bluetoothProvider = bluetoothProvider,
       _batteryProvider = batteryProvider,
       _manualProvider = manualProvider,
       _thermalProvider = thermalProvider,
       _thermalEstimate = thermalProvider is ThermalEstimateProvider
           ? thermalProvider
           : null;

  final IndoorTemperatureProvider _ambientProvider;
  final IndoorTemperatureProvider _bluetoothProvider;
  final IndoorTemperatureProvider _batteryProvider;
  final IndoorTemperatureProvider _manualProvider;
  final IndoorTemperatureProvider _thermalProvider;
  final ThermalEstimateProvider? _thermalEstimate;

  /// Records a manual room-temperature calibration against the last estimate.
  Future<({bool saved, bool poorConditions})> calibrate({
    required double actualRoomCelsius,
  }) async {
    var snapshot = _thermalEstimate?.lastSnapshot;
    var current = _thermalEstimate?.lastResult;
    if (snapshot == null || current == null) {
      await _thermalEstimate?.read();
      snapshot = _thermalEstimate?.lastSnapshot;
      current = _thermalEstimate?.lastResult;
    }
    if (_thermalEstimate == null || snapshot == null || current == null) {
      return (saved: false, poorConditions: false);
    }
    final profile = await _thermalEstimate.store.loadProfile();
    final next = _thermalEstimate.estimator.recordManualCalibration(
      profile: profile,
      current: current,
      snapshot: snapshot,
      actualRoomCelsius: actualRoomCelsius,
    );
    await _thermalEstimate.store.saveProfile(next);
    return (
      saved: true,
      poorConditions: next.points.isNotEmpty && next.points.last.poorConditions,
    );
  }

  /// Clears stored calibration points.
  Future<void> resetCalibration() async {
    if (_thermalEstimate == null) {
      return;
    }
    final profile = await _thermalEstimate.store.loadProfile();
    final next = _thermalEstimate.estimator.resetCalibration(profile);
    await _thermalEstimate.store.saveProfile(next);
  }

  /// Last estimator debug dump, when the thermal path ran.
  IndoorEstimateDebug? get lastDebug => _thermalEstimate?.lastResult?.debug;

  /// Last estimator result, when the thermal path ran.
  IndoorEstimateResult? get lastEstimate => _thermalEstimate?.lastResult;

  /// Last thermal snapshot, when one was read.
  ThermalSnapshot? get lastSnapshot => _thermalEstimate?.lastSnapshot;

  /// The thermal provider, for calibration.
  ThermalEstimateProvider? get thermalProvider => _thermalEstimate;

  /// Resolves one reading using either the explicit preference or automatic
  /// priority order. Independent of weather / location / network.
  Future<IndoorTemperatureReading?> resolve({
    required IndoorTemperaturePreference preference,
  }) async {
    if (preference == IndoorTemperaturePreference.automatic) {
      for (final provider in [
        _ambientProvider,
        _bluetoothProvider,
        _thermalProvider,
        _manualProvider,
      ]) {
        final reading = await _readAvailable(provider);
        if (reading != null) {
          return reading;
        }
      }
      return null;
    }

    return _readAvailable(_providerFor(preference));
  }

  /// Returns a snapshot of source availability for settings UI.
  Future<Map<IndoorTemperatureSource, bool>> availability() async {
    return {
      IndoorTemperatureSource.ambientSensor: await _ambientProvider
          .isAvailable(),
      IndoorTemperatureSource.bluetoothSensor: await _bluetoothProvider
          .isAvailable(),
      IndoorTemperatureSource.batteryTemperature: await _batteryProvider
          .isAvailable(),
      IndoorTemperatureSource.manual: await _manualProvider.isAvailable(),
      IndoorTemperatureSource.estimated: true,
    };
  }

  Future<IndoorTemperatureReading?> _readAvailable(
    IndoorTemperatureProvider provider,
  ) async {
    if (identical(provider, _thermalProvider) &&
        provider is ThermalEstimateProvider) {
      return provider.read();
    }
    if (!await provider.isAvailable()) {
      return null;
    }
    final values = await provider.temperatureStream.take(1).toList();
    if (values.isEmpty) {
      return null;
    }
    return IndoorTemperatureReading(
      celsius: values.first,
      source: provider.source,
    );
  }

  IndoorTemperatureProvider _providerFor(
    IndoorTemperaturePreference preference,
  ) {
    return switch (preference) {
      IndoorTemperaturePreference.automatic => _thermalProvider,
      IndoorTemperaturePreference.ambientSensor => _ambientProvider,
      IndoorTemperaturePreference.bluetoothSensor => _bluetoothProvider,
      IndoorTemperaturePreference.batteryTemperature => _batteryProvider,
      IndoorTemperaturePreference.manual => _manualProvider,
      IndoorTemperaturePreference.estimated => _thermalProvider,
    };
  }
}
