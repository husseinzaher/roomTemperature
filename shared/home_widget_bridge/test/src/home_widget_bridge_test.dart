// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';

void main() {
  group('HomeWidgetSnapshot', () {
    test('formats the clock as zero-padded HH:mm', () {
      expect(
        HomeWidgetSnapshot.formatClock(DateTime(2026, 1, 1, 9, 5)),
        '09:05',
      );
      expect(
        HomeWidgetSnapshot.formatClock(DateTime(2026, 8, 26, 18, 2)),
        '18:02',
      );
    });

    test('converts Celsius values with the supplied converter', () {
      final snapshot = HomeWidgetSnapshot.fromCelsius(
        roomTemperatureCelsius: 20,
        outsideTemperatureCelsius: 10,
        convertFromCelsius: (celsius) => celsius * 9 / 5 + 32,
        unitSymbol: '°F',
        sourceLabel: 'Battery Temperature',
        thresholdBreached: true,
        updatedAt: DateTime(2026, 1, 1, 14, 30),
      );

      expect(snapshot.roomTemperature, '68.0');
      expect(snapshot.outsideTemperature, '50.0');
      expect(snapshot.unitSymbol, '°F');
      expect(snapshot.sourceLabel, 'Battery Temperature');
      expect(snapshot.thresholdBreached, isTrue);
      expect(snapshot.updatedAtLabel, '14:30');
      expect(snapshot.locationLabel, isNull);
    });

    test('carries the reverse-geocoded locality when provided', () {
      final snapshot = HomeWidgetSnapshot.fromCelsius(
        roomTemperatureCelsius: 24,
        outsideTemperatureCelsius: 36,
        convertFromCelsius: (celsius) => celsius,
        unitSymbol: '°C',
        sourceLabel: 'Battery Temperature',
        thresholdBreached: false,
        updatedAt: DateTime(2026, 8, 26, 18, 3),
        locationLabel: 'Sandub',
      );

      expect(snapshot.locationLabel, 'Sandub');
      expect(snapshot.updatedAtLabel, '18:03');
    });

    test('keeps Celsius values when the converter is the identity', () {
      final snapshot = HomeWidgetSnapshot.fromCelsius(
        roomTemperatureCelsius: 24.56,
        outsideTemperatureCelsius: 21.04,
        convertFromCelsius: (celsius) => celsius,
        unitSymbol: '°C',
        sourceLabel: 'Phone Sensor',
        thresholdBreached: false,
        updatedAt: DateTime(2026),
      );

      expect(snapshot.roomTemperature, '24.6');
      expect(snapshot.outsideTemperature, '21.0');
      expect(snapshot.updatedAtLabel, '00:00');
    });
  });

  group('HomeWidgetBridge', () {
    test('can be instantiated', () {
      expect(HomeWidgetBridge(), isNotNull);
    });
  });
}
