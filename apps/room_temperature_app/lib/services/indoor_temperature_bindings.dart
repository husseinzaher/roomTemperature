import 'package:local_database/local_database.dart';
import 'package:room_temperature_app/services/ambient_sensor_service.dart';
import 'package:room_temperature_app/services/battery_temperature_service.dart';
import 'package:room_temperature_app/services/indoor_estimator_store.dart';
import 'package:room_temperature_app/services/indoor_temperature_service.dart';
import 'package:room_temperature_app/services/thermal_data_service.dart';
import 'package:settings_data/settings_data.dart';

/// Builds the same indoor stack used by the foreground app and WorkManager.
IndoorTemperatureService buildIndoorTemperatureService({
  required AppDatabase database,
  required DriftSettingsRepository settingsRepository,
}) {
  return IndoorTemperatureService(
    ambientProvider: const AndroidAmbientTemperatureProvider(
      AmbientSensorService(),
    ),
    bluetoothProvider: const BluetoothTemperatureProvider(),
    batteryProvider: const BatteryTemperatureProvider(
      BatteryTemperatureService(),
    ),
    manualProvider: ManualTemperatureProvider(
      () => settingsRepository
          .lastSettingsOrDefault()
          .manualIndoorTemperatureCelsius,
    ),
    thermalProvider: ThermalEstimateProvider(
      thermalData: const ThermalDataService(),
      store: IndoorEstimatorStore(database: database),
    ),
  );
}
