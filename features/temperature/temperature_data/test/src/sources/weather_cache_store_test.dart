import 'package:drift/native.dart';
import 'package:local_database/local_database.dart';
import 'package:temperature_data/temperature_data.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('WeatherCacheStore', () {
    late AppDatabase database;
    late WeatherCacheStore store;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      store = WeatherCacheStore(database);
    });

    tearDown(() => database.close());

    test('round-trips current weather and five-day forecast', () async {
      final weather = OutsideWeather(
        temperatureCelsius: 36,
        condition: WeatherCondition.fog,
        isDay: true,
        placeName: 'Sandub',
        forecastDays: [
          DailyForecast(
            date: DateTime(2026, 8, 26),
            condition: WeatherCondition.fog,
            maxCelsius: 40,
            minCelsius: 21,
          ),
          DailyForecast(
            date: DateTime(2026, 8, 27),
            condition: WeatherCondition.clear,
            maxCelsius: 39,
            minCelsius: 21,
          ),
        ],
      );

      await store.save(weather, at: DateTime.utc(2026, 8, 26, 12));
      final loaded = await store.load();
      expect(loaded, weather);
      expect(await store.loadedAt(), DateTime.utc(2026, 8, 26, 12));
    });

    test('returns null for corrupt cache instead of throwing', () async {
      await database.writeSetting(WeatherCacheStore.jsonKey, '{not-json');
      expect(await store.load(), isNull);
    });
  });

  group('OutsideWeather.tryFromJson', () {
    test('returns null when required fields are missing', () {
      expect(OutsideWeather.tryFromJson(const {}), isNull);
      expect(OutsideWeather.tryFromJson(null), isNull);
    });
  });
}
