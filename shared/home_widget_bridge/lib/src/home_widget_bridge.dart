import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:home_widget_bridge/src/home_widget_forecast_day.dart';
import 'package:home_widget_bridge/src/home_widget_place_row.dart';
import 'package:home_widget_bridge/src/home_widget_snapshot.dart';

/// {@template home_widget_bridge}
/// Shared bridge to the Android home-screen and lock-screen widgets.
///
/// Pushes the latest temperature reading into the platform's widget
/// storage and asks the OS to redraw every registered widget. A failure
/// while updating must never crash the app, so every platform call is
/// wrapped in a try/catch.
/// {@endtemplate}
class HomeWidgetBridge {
  /// {@macro home_widget_bridge}
  const HomeWidgetBridge();

  static const List<String> _widgetNames = [
    'RoomTempWidgetProvider',
    'RoomTempLockWidgetProvider',
    'RoomTempForecastWidgetProvider',
    'RoomTempPlacesWidgetProvider',
    'RoomTempCurrentWidgetProvider',
  ];

  static const String _roomTempKey = 'room_temp';
  static const String _outsideTempKey = 'outside_temp';
  static const String _unitSymbolKey = 'unit_symbol';
  static const String _sourceLabelKey = 'source_label';
  static const String _updatedAtKey = 'updated_at_label';
  static const String _clockKey = 'clock_label';
  static const String _thresholdBreachedKey = 'threshold_breached';
  static const String _locationLabelKey = 'location_label';
  static const String _dateLabelKey = 'date_label';
  static const String _shortDateLabelKey = 'short_date_label';
  static const String _conditionLabelKey = 'condition_label';
  static const String _conditionIconKey = 'condition_icon';
  static const String _feelsLikeKey = 'feels_like_label';
  static const String _humidityKey = 'humidity_label';
  static const String _windKey = 'wind_label';
  static const String _uvKey = 'uv_label';
  static const String _placeNameKey = 'place_name';
  static const String _placeAverageKey = 'place_average_label';
  static const String _legacyRoomTempKey = 'room_temp_c';
  static const String _legacyOutsideTempKey = 'outside_temp_c';

  /// Number of forecast slots written to SharedPreferences.
  static const int forecastSlotCount = 5;

  /// Number of place slots written to SharedPreferences.
  static const int placeSlotCount = 5;

  /// Pushes [snapshot] to every registered Android widget.
  ///
  /// Swallows and logs any failure so a widget-update error never crashes
  /// the app.
  Future<void> updateReading(HomeWidgetSnapshot snapshot) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        _roomTempKey,
        snapshot.roomTemperature,
      );
      await HomeWidget.saveWidgetData<String>(
        _outsideTempKey,
        snapshot.outsideTemperature,
      );
      await HomeWidget.saveWidgetData<String>(
        _unitSymbolKey,
        snapshot.unitSymbol,
      );
      await HomeWidget.saveWidgetData<String>(
        _sourceLabelKey,
        snapshot.sourceLabel,
      );
      await HomeWidget.saveWidgetData<String>(
        _updatedAtKey,
        snapshot.updatedAtLabel,
      );
      await HomeWidget.saveWidgetData<String>(
        _clockKey,
        snapshot.clockLabel ?? snapshot.updatedAtLabel,
      );
      await HomeWidget.saveWidgetData<bool>(
        _thresholdBreachedKey,
        snapshot.thresholdBreached,
      );
      await HomeWidget.saveWidgetData<String>(
        _locationLabelKey,
        snapshot.locationLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _dateLabelKey,
        snapshot.dateLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _shortDateLabelKey,
        snapshot.shortDateLabel ?? snapshot.dateLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _conditionLabelKey,
        snapshot.conditionLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _conditionIconKey,
        snapshot.conditionIcon ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _feelsLikeKey,
        snapshot.feelsLikeLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _humidityKey,
        snapshot.humidityLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _windKey,
        snapshot.windLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _uvKey,
        snapshot.uvLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _placeNameKey,
        snapshot.placeName ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _placeAverageKey,
        snapshot.placeAverageLabel ?? '',
      );
      for (var i = 0; i < forecastSlotCount; i++) {
        final day = i < snapshot.forecast.length
            ? snapshot.forecast[i]
            : HomeWidgetForecastDay.empty;
        await HomeWidget.saveWidgetData<String>(
          'forecast_${i}_label',
          day.label,
        );
        await HomeWidget.saveWidgetData<String>(
          'forecast_${i}_icon',
          day.iconKey,
        );
        await HomeWidget.saveWidgetData<String>(
          'forecast_${i}_range',
          day.range,
        );
        await HomeWidget.saveWidgetData<String>(
          'forecast_${i}_high',
          day.high,
        );
      }
      for (var i = 0; i < placeSlotCount; i++) {
        final place = i < snapshot.places.length
            ? snapshot.places[i]
            : HomeWidgetPlaceRow.empty;
        await HomeWidget.saveWidgetData<String>(
          'place_${i}_name',
          place.name,
        );
        await HomeWidget.saveWidgetData<String>(
          'place_${i}_temp',
          place.temperature,
        );
        await HomeWidget.saveWidgetData<String>(
          'place_${i}_subtitle',
          place.subtitle,
        );
      }
      await HomeWidget.saveWidgetData<String>(
        _legacyRoomTempKey,
        snapshot.roomTemperature,
      );
      await HomeWidget.saveWidgetData<String>(
        _legacyOutsideTempKey,
        snapshot.outsideTemperature,
      );

      for (final name in _widgetNames) {
        await HomeWidget.updateWidget(androidName: name);
      }
    } on Exception catch (error, stackTrace) {
      debugPrint('HomeWidgetBridge.updateReading failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Persists the global refresh interval so the widget can read the same
  /// value the app uses. Scheduling itself is WorkManager, not this key.
  static const String refreshIntervalMinutesKey = 'refresh_interval_minutes';

  /// Writes [minutes] into widget SharedPreferences.
  Future<void> saveRefreshIntervalMinutes(int minutes) async {
    try {
      await HomeWidget.saveWidgetData<int>(
        refreshIntervalMinutesKey,
        minutes,
      );
    } on Exception catch (error, stackTrace) {
      debugPrint(
        'HomeWidgetBridge.saveRefreshIntervalMinutes failed: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
