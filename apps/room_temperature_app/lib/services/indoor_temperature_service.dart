import 'package:room_temperature_app/services/ambient_sensor_service.dart';
import 'package:room_temperature_app/services/battery_temperature_service.dart';
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
  if (value != null) yield value;
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

/// Weather-derived estimate provider.
class EstimatedTemperatureProvider implements IndoorTemperatureProvider {
  /// Creates an estimated temperature provider.
  const EstimatedTemperatureProvider({
    required this.weather,
    required this.indoorOffsetCelsius,
    this.estimator = const RoomTemperatureEstimator(),
  });

  /// The outside weather used for the estimate.
  final OutsideWeather weather;

  /// The user calibration offset.
  final double indoorOffsetCelsius;

  /// The estimator.
  final RoomTemperatureEstimator estimator;

  @override
  IndoorTemperatureSource get source => IndoorTemperatureSource.estimated;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Stream<double> get temperatureStream => _oneShotStream(() async {
    return estimator.estimate(
      outsideTemperatureCelsius: weather.temperatureCelsius,
      indoorOffsetCelsius: indoorOffsetCelsius,
    );
  });
}

/// Resolves the active indoor-temperature source from user settings.
///
/// Automatic priority:
/// 1. Android ambient temperature sensor
/// 2. Bluetooth BLE temperature sensor
/// 3. Battery temperature
/// 4. Manual temperature
/// 5. Weather-based estimate
class IndoorTemperatureService {
  /// Creates an indoor-temperature service.
  const IndoorTemperatureService({
    required this._ambientProvider,
    required this._bluetoothProvider,
    required this._batteryProvider,
    required this._manualProvider,
  });

  final IndoorTemperatureProvider _ambientProvider;
  final IndoorTemperatureProvider _bluetoothProvider;
  final IndoorTemperatureProvider _batteryProvider;
  final IndoorTemperatureProvider _manualProvider;

  /// Resolves one reading using either the explicit preference or automatic
  /// priority order.
  Future<IndoorTemperatureReading?> resolve({
    required IndoorTemperaturePreference preference,
    required OutsideWeather weather,
    required double indoorOffsetCelsius,
  }) async {
    final estimatedProvider = EstimatedTemperatureProvider(
      weather: weather,
      indoorOffsetCelsius: indoorOffsetCelsius,
    );

    if (preference == IndoorTemperaturePreference.automatic) {
      for (final provider in [
        _ambientProvider,
        _bluetoothProvider,
        _batteryProvider,
        _manualProvider,
        estimatedProvider,
      ]) {
        final reading = await _readAvailable(provider);
        if (reading != null) return reading;
      }
      return null;
    }

    return _readAvailable(_providerFor(preference, estimatedProvider));
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
    if (!await provider.isAvailable()) return null;
    final values = await provider.temperatureStream.take(1).toList();
    if (values.isEmpty) return null;
    return IndoorTemperatureReading(
      celsius: values.first,
      source: provider.source,
    );
  }

  IndoorTemperatureProvider _providerFor(
    IndoorTemperaturePreference preference,
    EstimatedTemperatureProvider estimatedProvider,
  ) {
    return switch (preference) {
      IndoorTemperaturePreference.automatic => estimatedProvider,
      IndoorTemperaturePreference.ambientSensor => _ambientProvider,
      IndoorTemperaturePreference.bluetoothSensor => _bluetoothProvider,
      IndoorTemperaturePreference.batteryTemperature => _batteryProvider,
      IndoorTemperaturePreference.manual => _manualProvider,
      IndoorTemperaturePreference.estimated => estimatedProvider,
    };
  }
}
