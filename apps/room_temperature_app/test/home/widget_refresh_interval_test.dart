import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:settings_domain/settings_domain.dart';

void main() {
  test('all widgets disable independent Android period updates', () {
    const infos = [
      'android/app/src/main/res/xml/room_temp_widget_info.xml',
      'android/app/src/main/res/xml/room_temp_lock_widget_info.xml',
      'android/app/src/main/res/xml/room_temp_forecast_widget_info.xml',
      'android/app/src/main/res/xml/room_temp_places_widget_info.xml',
      'android/app/src/main/res/xml/room_temp_current_widget_info.xml',
    ];
    for (final path in infos) {
      expect(
        File(path).readAsStringSync(),
        contains('android:updatePeriodMillis="0"'),
        reason: path,
      );
    }
  });

  test('widget SharedPreferences key is the global interval', () {
    expect(
      HomeWidgetBridge.refreshIntervalMinutesKey,
      'refresh_interval_minutes',
    );
    expect(RefreshInterval.clamp(const Duration(minutes: 5)).inMinutes, 5);
    expect(RefreshInterval.clamp(const Duration(hours: 1)).inMinutes, 60);
  });

  test('main widget registers resize and size-class layouts', () {
    final home = File(
      'android/app/src/main/res/xml/room_temp_widget_info.xml',
    ).readAsStringSync();
    expect(home, contains('android:resizeMode="horizontal|vertical"'));
    expect(
      File(
        'android/app/src/main/res/layout/room_temp_widget.xml',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'android/app/src/main/res/layout/room_temp_widget_md.xml',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'android/app/src/main/res/layout/room_temp_widget_sm.xml',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'android/app/src/main/res/layout/room_temp_widget_xs.xml',
      ).existsSync(),
      isTrue,
    );
    expect(
      File('android/app/src/main/res/layout/room_temp_widget.xml')
          .readAsStringSync(),
      isNot(contains('<View')),
      reason: 'App widgets cannot inflate the base View class',
    );
  });
}
