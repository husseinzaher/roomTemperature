import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/services/ambient_sensor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AmbientSensorService', () {
    test(
      'readCelsius returns null when no platform implementation is '
      'registered (the common case: most devices have no ambient sensor)',
      () async {
        const service = AmbientSensorService();
        expect(await service.readCelsius(), isNull);
      },
    );
  });
}
