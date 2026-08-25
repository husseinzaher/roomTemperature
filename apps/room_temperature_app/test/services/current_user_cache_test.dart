import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/services/current_user_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CurrentUserCache', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('read returns null when nothing has been saved', () async {
      expect(await const CurrentUserCache().read(), isNull);
    });

    test('save then read round-trips the user id', () async {
      const cache = CurrentUserCache();
      await cache.save('user-123');
      expect(await cache.read(), 'user-123');
    });

    test('saving null clears the cached user id', () async {
      const cache = CurrentUserCache();
      await cache.save('user-123');
      await cache.save(null);
      expect(await cache.read(), isNull);
    });
  });
}
