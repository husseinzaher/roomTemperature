import 'package:temperature_domain/temperature_domain.dart';
import 'package:test/test.dart';

void main() {
  group('RoomTemperatureEstimator', () {
    const estimator = RoomTemperatureEstimator();

    test('adds a positive offset to the outside temperature', () {
      final result = estimator.estimate(
        outsideTemperatureCelsius: 20,
        indoorOffsetCelsius: 3,
      );

      expect(result, 23);
    });

    test('adds a negative offset to the outside temperature', () {
      final result = estimator.estimate(
        outsideTemperatureCelsius: 20,
        indoorOffsetCelsius: -5,
      );

      expect(result, 15);
    });

    test('returns the outside temperature unchanged for a zero offset', () {
      final result = estimator.estimate(
        outsideTemperatureCelsius: 18.5,
        indoorOffsetCelsius: 0,
      );

      expect(result, 18.5);
    });

    test('handles sub-zero outside temperatures', () {
      final result = estimator.estimate(
        outsideTemperatureCelsius: -10,
        indoorOffsetCelsius: 4,
      );

      expect(result, -6);
    });

    test('handles fractional inputs', () {
      final result = estimator.estimate(
        outsideTemperatureCelsius: 21.25,
        indoorOffsetCelsius: 1.75,
      );

      expect(result, 23.0);
    });

    test(
      'is pure: repeated calls with the same inputs return the same value',
      () {
        final first = estimator.estimate(
          outsideTemperatureCelsius: 30,
          indoorOffsetCelsius: -2,
        );
        final second = estimator.estimate(
          outsideTemperatureCelsius: 30,
          indoorOffsetCelsius: -2,
        );

        expect(first, second);
      },
    );
  });
}
