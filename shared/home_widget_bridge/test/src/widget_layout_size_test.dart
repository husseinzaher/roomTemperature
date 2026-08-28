import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';

void main() {
  group('WidgetLayoutClassifier', () {
    test('classifies very small from min width or height', () {
      expect(
        WidgetLayoutClassifier.classify(minWidthDp: 100, minHeightDp: 200),
        WidgetLayoutSize.verySmall,
      );
      expect(
        WidgetLayoutClassifier.classify(minWidthDp: 200, minHeightDp: 40),
        WidgetLayoutSize.verySmall,
      );
    });

    test('classifies small', () {
      expect(
        WidgetLayoutClassifier.classify(minWidthDp: 150, minHeightDp: 80),
        WidgetLayoutSize.small,
      );
    });

    test('classifies medium', () {
      expect(
        WidgetLayoutClassifier.classify(minWidthDp: 200, minHeightDp: 140),
        WidgetLayoutSize.medium,
      );
    });

    test('classifies large at 4x4-ish dimensions', () {
      expect(
        WidgetLayoutClassifier.classify(minWidthDp: 250, minHeightDp: 220),
        WidgetLayoutSize.large,
      );
    });

    test('forecast day count follows size priority', () {
      expect(
        WidgetLayoutClassifier.forecastDayCount(WidgetLayoutSize.verySmall),
        1,
      );
      expect(
        WidgetLayoutClassifier.forecastDayCount(WidgetLayoutSize.small),
        2,
      );
      expect(
        WidgetLayoutClassifier.forecastDayCount(WidgetLayoutSize.medium),
        2,
      );
      expect(
        WidgetLayoutClassifier.forecastDayCount(WidgetLayoutSize.large),
        5,
      );
    });

    test('place count follows size priority', () {
      expect(WidgetLayoutClassifier.placeCount(WidgetLayoutSize.verySmall), 1);
      expect(WidgetLayoutClassifier.placeCount(WidgetLayoutSize.small), 1);
      expect(WidgetLayoutClassifier.placeCount(WidgetLayoutSize.medium), 3);
      expect(WidgetLayoutClassifier.placeCount(WidgetLayoutSize.large), 5);
    });
  });
}
