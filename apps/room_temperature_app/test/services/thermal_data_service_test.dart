import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/services/thermal_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('room_temperature/thermal_data');
  const service = ThermalDataService();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('readSnapshot returns null when no plugin is registered', () async {
    expect(await service.readSnapshot(), isNull);
  });

  test(
    'readSnapshot parses a local thermal map with no network fields',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'getThermalSnapshot');
            return <String, dynamic>{
              'timestampMs': DateTime(2026, 1, 1).millisecondsSinceEpoch,
              'batteryCelsius': 29.4,
              'isCharging': false,
              'batteryVoltageMillivolts': 3920,
              'batteryCurrentMicroamps': -420000,
              'screenOn': true,
              'thermalStatus': 0,
              'zones': [
                {'name': 'sdr0', 'temperatureCelsius': 27.0},
                {'name': 'cpu-0', 'temperatureCelsius': 47.5},
              ],
            };
          });

      final snapshot = await service.readSnapshot();
      expect(snapshot, isNotNull);
      expect(snapshot!.batteryCelsius, 29.4);
      expect(snapshot.batteryVoltageMillivolts, 3920);
      expect(snapshot.isCharging, isFalse);
      expect(snapshot.zones.first.name, 'sdr0');
      expect(snapshot.toJson().containsKey('weather'), isFalse);
    },
  );
}
