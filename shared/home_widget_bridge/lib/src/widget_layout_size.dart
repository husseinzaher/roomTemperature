/// Size class for Android home-screen widgets, derived from
/// `OPTION_APPWIDGET_MIN_WIDTH` / `MIN_HEIGHT` in dp.
///
/// Breakpoints match `RoomTempWidgetViews` in Kotlin. They are not launcher
/// cell counts; the system reports the actual min width/height after resize.
enum WidgetLayoutSize {
  /// Too small for anything but one temperature.
  verySmall,

  /// Inside, outside, and condition.
  small,

  /// Time, temps, weather, and a short forecast.
  medium,

  /// Full dashboard including 5-day forecast and optional place average.
  large,
}

/// Classifies widget min-width/height (dp) into a [WidgetLayoutSize].
class WidgetLayoutClassifier {
  /// Very-small max width (dp).
  static const int verySmallMaxWidthDp = 110;

  /// Very-small max height (dp).
  static const int verySmallMaxHeightDp = 55;

  /// Small max width (dp).
  static const int smallMaxWidthDp = 180;

  /// Small max height (dp).
  static const int smallMaxHeightDp = 110;

  /// Medium max width (dp).
  static const int mediumMaxWidthDp = 250;

  /// Medium max height (dp).
  static const int mediumMaxHeightDp = 180;

  /// Picks a layout from Android's reported min width/height.
  static WidgetLayoutSize classify({
    required int minWidthDp,
    required int minHeightDp,
  }) {
    if (minWidthDp < verySmallMaxWidthDp ||
        minHeightDp < verySmallMaxHeightDp) {
      return WidgetLayoutSize.verySmall;
    }
    if (minWidthDp < smallMaxWidthDp || minHeightDp < smallMaxHeightDp) {
      return WidgetLayoutSize.small;
    }
    if (minWidthDp < mediumMaxWidthDp || minHeightDp < mediumMaxHeightDp) {
      return WidgetLayoutSize.medium;
    }
    return WidgetLayoutSize.large;
  }

  /// How many forecast days a dedicated forecast widget should show.
  static int forecastDayCount(WidgetLayoutSize size) {
    return switch (size) {
      WidgetLayoutSize.verySmall => 1,
      WidgetLayoutSize.small => 2,
      WidgetLayoutSize.medium => 2,
      WidgetLayoutSize.large => 5,
    };
  }

  /// How many places a dedicated places widget should show.
  static int placeCount(WidgetLayoutSize size) {
    return switch (size) {
      WidgetLayoutSize.verySmall => 1,
      WidgetLayoutSize.small => 1,
      WidgetLayoutSize.medium => 3,
      WidgetLayoutSize.large => 5,
    };
  }
}
