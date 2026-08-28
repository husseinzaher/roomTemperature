/// {@template home_widget_forecast_day}
/// One formatted forecast column on the home-screen widget.
/// {@endtemplate}
class HomeWidgetForecastDay {
  /// {@macro home_widget_forecast_day}
  const HomeWidgetForecastDay({
    required this.label,
    required this.iconKey,
    required this.range,
    this.high = '',
  });

  /// `Today`, `Tomorrow`, or a weekday like `MON`.
  final String label;

  /// Weather condition name, used to pick an Android drawable.
  final String iconKey;

  /// High/low already converted, e.g. `40°C/21°C`.
  final String range;

  /// High only, e.g. `38°`, for very small forecast widgets.
  final String high;

  /// Empty placeholder used to pad a missing day.
  static const HomeWidgetForecastDay empty = HomeWidgetForecastDay(
    label: '',
    iconKey: '',
    range: '',
  );

  /// Whether this column should be shown.
  bool get isEmpty => label.isEmpty;
}
