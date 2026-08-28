import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget_bridge/home_widget_bridge.dart';
import 'package:settings_domain/settings_domain.dart';

void main() {
  test('home and lock widgets disable independent Android period updates', () {
    final home = File(
      'android/app/src/main/res/xml/room_temp_widget_info.xml',
    ).readAsStringSync();
    final lock = File(
      'android/app/src/main/res/xml/room_temp_lock_widget_info.xml',
    ).readAsStringSync();

    expect(home, contains('android:updatePeriodMillis="0"'));
    expect(lock, contains('android:updatePeriodMillis="0"'));
  });

  test('widget SharedPreferences key is the global interval', () {
    expect(
      HomeWidgetBridge.refreshIntervalMinutesKey,
      'refresh_interval_minutes',
    );
    expect(RefreshInterval.clamp(const Duration(minutes: 5)).inMinutes, 5);
    expect(RefreshInterval.clamp(const Duration(hours: 1)).inMinutes, 60);
  });
}
