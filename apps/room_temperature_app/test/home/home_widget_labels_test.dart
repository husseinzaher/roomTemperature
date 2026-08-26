import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:room_temperature_app/home/home_widget_labels.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';

void main() {
  group('homeWidgetConditionLabel', () {
    test('maps fog to Haze', () {
      expect(homeWidgetConditionLabel(WeatherCondition.fog), 'Haze');
    });
  });

  group('homeWidgetForecastDayLabel', () {
    final now = DateTime(2026, 8, 26);

    test('uses Today and Tomorrow for the next two days', () {
      expect(homeWidgetForecastDayLabel(now, now), 'Today');
      expect(
        homeWidgetForecastDayLabel(DateTime(2026, 8, 27), now),
        'Tomorrow',
      );
    });

    test('uses MM/dd after tomorrow', () {
      expect(
        homeWidgetForecastDayLabel(DateTime(2026, 8, 28), now),
        '08/28',
      );
    });
  });

  group('homeWidgetForecast', () {
    test('formats four high/low columns', () {
      final weather = OutsideWeather(
        temperatureCelsius: 36,
        condition: WeatherCondition.fog,
        isDay: true,
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

      final days = homeWidgetForecast(
        weather: weather,
        units: Units.celsius,
        now: DateTime(2026, 8, 26),
      );

      expect(days, hasLength(4));
      expect(days[0].label, 'Today');
      expect(days[0].range, '40°C/21°C');
      expect(days[0].iconKey, 'fog');
      expect(days[1].label, 'Tomorrow');
      expect(days[2].isEmpty, isTrue);
    });
  });
}
