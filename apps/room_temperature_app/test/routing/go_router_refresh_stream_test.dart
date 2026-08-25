import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/routing/go_router_refresh_stream.dart';

void main() {
  group('GoRouterRefreshStream', () {
    test('constructing it does not throw, even for an empty stream', () {
      final refreshStream = GoRouterRefreshStream(const Stream.empty());
      addTearDown(refreshStream.dispose);
    });

    test('notifies on every stream event', () async {
      final controller = StreamController<int>.broadcast();
      addTearDown(controller.close);

      final refreshStream = GoRouterRefreshStream(controller.stream);
      addTearDown(refreshStream.dispose);

      var notifyCount = 0;
      refreshStream.addListener(() => notifyCount++);

      controller
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);

      expect(notifyCount, 2);
    });
  });
}
