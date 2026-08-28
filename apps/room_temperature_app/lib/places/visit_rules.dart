/// Configurable visit-detection constants.
///
/// Nearby GPS samples are grouped into one dwell session. These values are
/// not user-facing settings.
class VisitRules {
  /// Samples within this radius belong to the same visit/place.
  static const double groupingRadiusMeters = 100;

  /// A session is stored only after the user has stayed this long.
  static const Duration minDwell = Duration(minutes: 30);

  /// Indoor estimates below this are ignored as invalid.
  static const double minValidIndoorC = 5;

  /// Indoor estimates above this are ignored as invalid.
  static const double maxValidIndoorC = 45;

  /// Whether [celsius] is a plausible indoor estimate.
  ///
  /// Battery temperature is never passed here — callers must use the
  /// calibrated indoor estimator output.
  static bool isValidIndoorCelsius(double? celsius) {
    if (celsius == null) {
      return false;
    }
    if (celsius.isNaN || celsius.isInfinite) {
      return false;
    }
    return celsius >= minValidIndoorC && celsius <= maxValidIndoorC;
  }
}
