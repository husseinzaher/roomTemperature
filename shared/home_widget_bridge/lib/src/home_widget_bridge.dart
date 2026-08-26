import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
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

  static const String _homeWidgetName = 'RoomTempWidgetProvider';
  static const String _lockWidgetName = 'RoomTempLockWidgetProvider';

  static const String _roomTempKey = 'room_temp';
  static const String _outsideTempKey = 'outside_temp';
  static const String _unitSymbolKey = 'unit_symbol';
  static const String _sourceLabelKey = 'source_label';
  static const String _updatedAtKey = 'updated_at_label';
  static const String _thresholdBreachedKey = 'threshold_breached';
  static const String _locationLabelKey = 'location_label';
  static const String _legacyRoomTempKey = 'room_temp_c';
  static const String _legacyOutsideTempKey = 'outside_temp_c';

  /// Pushes [snapshot] to the Android home and lock-screen widgets.
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
      await HomeWidget.saveWidgetData<bool>(
        _thresholdBreachedKey,
        snapshot.thresholdBreached,
      );
      await HomeWidget.saveWidgetData<String>(
        _locationLabelKey,
        snapshot.locationLabel ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        _legacyRoomTempKey,
        snapshot.roomTemperature,
      );
      await HomeWidget.saveWidgetData<String>(
        _legacyOutsideTempKey,
        snapshot.outsideTemperature,
      );

      await HomeWidget.updateWidget(androidName: _homeWidgetName);
      await HomeWidget.updateWidget(androidName: _lockWidgetName);
    } on Exception catch (error, stackTrace) {
      debugPrint('HomeWidgetBridge.updateReading failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
