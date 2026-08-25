/// {@template room_temperature_estimator}
/// Estimates the room temperature from the real outside temperature and a
/// user-adjustable indoor offset.
///
/// This is pure business logic with no I/O: given the same inputs it always
/// returns the same output, which makes it trivial to unit test. It does
/// NOT decide whether a real sensor reading should be preferred instead —
/// that decision belongs to the caller (see the presentation layer's
/// `TemperatureCubit.refresh`), since a real ambient sensor is not available
/// on most phones and this estimator is only ever a fallback.
/// {@endtemplate}
class RoomTemperatureEstimator {
  /// {@macro room_temperature_estimator}
  const RoomTemperatureEstimator();

  /// Estimates the room temperature in Celsius by adding [indoorOffsetCelsius]
  /// to [outsideTemperatureCelsius].
  double estimate({
    required double outsideTemperatureCelsius,
    required double indoorOffsetCelsius,
  }) => outsideTemperatureCelsius + indoorOffsetCelsius;
}
