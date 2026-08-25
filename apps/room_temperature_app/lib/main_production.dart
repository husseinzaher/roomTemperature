import 'package:room_temperature_app/app/app.dart';
import 'package:room_temperature_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
