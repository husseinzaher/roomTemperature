import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/services/battery_temperature_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('room_temperature/battery_temperature');
  const service = BatteryTemperatureService();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('BatteryTemperatureService.celsiusFromRaw', () {
    test('converts tenths of a degree (365 → 36.5)', () {
      expect(BatteryTemperatureService.celsiusFromRaw(365), 36.5);
    });

    test('leaves already-converted Celsius values unchanged', () {
      expect(BatteryTemperatureService.celsiusFromRaw(36.5), 36.5);
    });
  });

  group('BatteryTemperatureService', () {
    test('readCelsius returns null when no plugin is registered', () async {
      expect(await service.readCelsius(), isNull);
    });

    test('isAvailable returns false when no plugin is registered', () async {
      expect(await service.isAvailable(), isFalse);
    });

    test('readCelsius converts a raw tenths value from the platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getBatteryTemperature') return 365;
            return null;
          });

      expect(await service.readCelsius(), 36.5);
    });

    test('readCelsius accepts an already converted Celsius value', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getBatteryTemperature') return 36.5;
            return null;
          });

      expect(await service.readCelsius(), 36.5);
    });

    test(
      'isAvailable is true when the platform reports a battery temp',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'hasBatteryTemperature') return true;
              return null;
            });

        expect(await service.isAvailable(), isTrue);
      },
    );
  });
}
