import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/services/background_data_refresh.dart';
import 'package:temperature_domain/temperature_domain.dart';

void main() {
  group('BackgroundDataRefresh', () {
    const indoor = IndoorTemperatureReading(
      celsius: 23.4,
      source: IndoorTemperatureSource.estimated,
      confidence: 0.8,
    );
    const weather = OutsideWeather(
      temperatureCelsius: 30,
      condition: WeatherCondition.clear,
      isDay: true,
    );
    final cached = Reading(
      roomTemperatureCelsius: 22,
      roomTemperatureSource: RoomTemperatureSource.estimated,
      outsideTemperatureCelsius: 19,
      timestamp: DateTime.utc(2026),
    );

    test('updates indoor when weather fetch fails', () async {
      Reading? persisted;
      Reading? widgetReading;
      var thresholds = 0;

      await BackgroundDataRefresh(
        resolveIndoor: () async => indoor,
        fetchWeather: () async => throw Exception('offline'),
        readLatest: () async => cached,
        persist: (reading) async => persisted = reading,
        syncWidget: (reading, _) async => widgetReading = reading,
        checkThresholds: () async => thresholds++,
      ).run();

      expect(persisted?.roomTemperatureCelsius, 23.4);
      expect(persisted?.outsideTemperatureCelsius, 19);
      expect(widgetReading?.roomTemperatureCelsius, 23.4);
      expect(thresholds, 1);
    });

    test('indoor works with no internet and no cached outdoor', () async {
      Reading? persisted;
      Reading? widgetReading;

      await BackgroundDataRefresh(
        resolveIndoor: () async => indoor,
        fetchWeather: () async => throw Exception('offline'),
        readLatest: () async => null,
        persist: (reading) async => persisted = reading,
        syncWidget: (reading, _) async => widgetReading = reading,
        checkThresholds: () async {},
      ).run();

      expect(widgetReading?.roomTemperatureCelsius, 23.4);
      expect(widgetReading?.outsideTemperatureCelsius, isNull);
      expect(persisted?.roomTemperatureCelsius, 23.4);
    });

    test('keeps cached outdoor data when weather fails', () async {
      Reading? persisted;

      await BackgroundDataRefresh(
        resolveIndoor: () async => indoor,
        fetchWeather: () async => null,
        readLatest: () async => cached,
        persist: (reading) async => persisted = reading,
        syncWidget: (reading, weather) async {},
        checkThresholds: () async {},
      ).run();

      expect(persisted?.outsideTemperatureCelsius, 19);
    });

    test('weather success still publishes indoor', () async {
      Reading? persisted;

      await BackgroundDataRefresh(
        resolveIndoor: () async => indoor,
        fetchWeather: () async => weather,
        readLatest: () async => cached,
        persist: (reading) async => persisted = reading,
        syncWidget: (reading, weather) async {},
        checkThresholds: () async {},
      ).run();

      expect(persisted?.roomTemperatureCelsius, 23.4);
      expect(persisted?.outsideTemperatureCelsius, 30);
    });
  });
}
