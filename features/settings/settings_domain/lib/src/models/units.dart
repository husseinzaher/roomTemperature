/// The temperature unit the user prefers to see values displayed in.
enum Units {
  /// Degrees Celsius.
  celsius,

  /// Degrees Fahrenheit.
  fahrenheit,
}

/// Conversion and display helpers for [Units].
extension UnitsX on Units {
  /// The display symbol for this unit (`'°C'` or `'°F'`).
  String get symbol {
    switch (this) {
      case Units.celsius:
        return '°C';
      case Units.fahrenheit:
        return '°F';
    }
  }

  /// Converts a Celsius value into this unit.
  ///
  /// Returns [celsius] unchanged when this unit is [Units.celsius], or the
  /// Fahrenheit-converted value (`c * 9/5 + 32`) when it is
  /// [Units.fahrenheit].
  double fromCelsius(double celsius) {
    switch (this) {
      case Units.celsius:
        return celsius;
      case Units.fahrenheit:
        return celsius * 9 / 5 + 32;
    }
  }
}
