import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// {@template home_widget_bridge}
/// Shared bridge to the Android home-screen widget
///
/// Pushes the latest temperature reading into the platform's home widget
/// storage and asks the OS to redraw the widget. A failure while updating
/// the widget must never crash the app, so every platform call is wrapped
/// in a try/catch.
/// {@endtemplate}
class HomeWidgetBridge {
  /// {@macro home_widget_bridge}
  const HomeWidgetBridge();

  static const String _androidWidgetName = 'RoomTempWidgetProvider';

  static const String _roomTempKey = 'room_temp_c';
  static const String _outsideTempKey = 'outside_temp_c';
  static const String _updatedAtKey = 'updated_at_label';
  static const String _thresholdBreachedKey = 'threshold_breached';

  /// Pushes the latest reading to the Android home-screen widget.
  ///
  /// Swallows and logs any failure so a widget-update error never crashes
  /// the app.
  Future<void> updateReading({
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
    required bool isEstimatedRoomTemperature,
    required bool thresholdBreached,
    required DateTime updatedAt,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        _roomTempKey,
        roomTemperatureCelsius.toStringAsFixed(1),
      );
      await HomeWidget.saveWidgetData<String>(
        _outsideTempKey,
        outsideTemperatureCelsius.toStringAsFixed(1),
      );
      await HomeWidget.saveWidgetData<String>(
        _updatedAtKey,
        _formatUpdatedAt(updatedAt),
      );
      await HomeWidget.saveWidgetData<bool>(
        _thresholdBreachedKey,
        thresholdBreached,
      );

      await HomeWidget.updateWidget(androidName: _androidWidgetName);
    } on Exception catch (error, stackTrace) {
      debugPrint('HomeWidgetBridge.updateReading failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _formatUpdatedAt(DateTime updatedAt) {
    final hour = updatedAt.hour.toString().padLeft(2, '0');
    final minute = updatedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
