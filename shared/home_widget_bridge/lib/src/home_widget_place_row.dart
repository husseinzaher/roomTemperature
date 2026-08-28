/// {@template home_widget_place_row}
/// One formatted place row for the places home-screen widget.
/// {@endtemplate}
class HomeWidgetPlaceRow {
  /// {@macro home_widget_place_row}
  const HomeWidgetPlaceRow({
    required this.name,
    required this.temperature,
    this.subtitle = '',
  });

  /// Place name, e.g. `Home`.
  final String name;

  /// Average indoor temperature already converted, e.g. `24.1`.
  final String temperature;

  /// Optional last-visit label, e.g. `Today`.
  final String subtitle;

  /// Empty placeholder used to pad a missing slot.
  static const HomeWidgetPlaceRow empty = HomeWidgetPlaceRow(
    name: '',
    temperature: '',
  );

  /// Whether this row should be shown.
  bool get isEmpty => name.isEmpty;
}
