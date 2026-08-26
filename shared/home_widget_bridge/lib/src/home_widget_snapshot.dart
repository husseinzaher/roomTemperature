/// {@template home_widget_snapshot}
/// Formatted reading the Android home and lock-screen widgets render.
///
/// Conversion into the user's unit happens before construction so this
/// package stays independent of the settings domain.
/// {@endtemplate}
class HomeWidgetSnapshot {
  /// {@macro home_widget_snapshot}
  const HomeWidgetSnapshot({
    required this.roomTemperature,
    required this.outsideTemperature,
    required this.unitSymbol,
    required this.sourceLabel,
    required this.thresholdBreached,
    required this.updatedAtLabel,
    this.locationLabel,
  });

  /// Builds a snapshot from Celsius values, converting with
  /// [convertFromCelsius].
  factory HomeWidgetSnapshot.fromCelsius({
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
    required double Function(double celsius) convertFromCelsius,
    required String unitSymbol,
    required String sourceLabel,
    required bool thresholdBreached,
    required DateTime updatedAt,
    String? locationLabel,
  }) {
    return HomeWidgetSnapshot(
      roomTemperature: convertFromCelsius(
        roomTemperatureCelsius,
      ).toStringAsFixed(1),
      outsideTemperature: convertFromCelsius(
        outsideTemperatureCelsius,
      ).toStringAsFixed(1),
      unitSymbol: unitSymbol,
      sourceLabel: sourceLabel,
      thresholdBreached: thresholdBreached,
      updatedAtLabel: formatClock(updatedAt),
      locationLabel: locationLabel,
    );
  }

  /// Indoor temperature already converted and rounded, e.g. `24.5`.
  final String roomTemperature;

  /// Outdoor temperature already converted and rounded, e.g. `21.0`.
  final String outsideTemperature;

  /// Display unit, e.g. `°C`.
  final String unitSymbol;

  /// Provenance shown on the widget, e.g. `Battery Temperature`.
  final String sourceLabel;

  /// Reverse-geocoded locality, e.g. `Sandub`. Null hides the location row.
  final String? locationLabel;

  /// Whether the indoor value is outside the user's alert range.
  final bool thresholdBreached;

  /// Clock time the reading was taken, `HH:mm`.
  final String updatedAtLabel;

  /// Formats [value] as a 24-hour `HH:mm` clock time.
  static String formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
