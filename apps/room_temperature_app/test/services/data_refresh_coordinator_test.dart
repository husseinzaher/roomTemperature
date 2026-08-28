import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_temperature_app/services/data_refresh_coordinator.dart';
import 'package:settings_domain/settings_domain.dart';

void main() {
  group('DataRefreshCoordinator', () {
    late StreamController<Duration> intervals;
    late List<Duration> background;
    late List<Duration> widgetPersisted;
    late int publishes;
    late int samples;

    DataRefreshCoordinator buildCoordinator({
      Duration Function()? readInterval,
    }) {
      return DataRefreshCoordinator(
        readInterval: readInterval ?? () => RefreshInterval.defaultInterval,
        intervalChanges: intervals.stream,
        publishRefresh: () async => publishes++,
        sampleIndoor: () async => samples++,
        rescheduleBackground: (interval) async => background.add(interval),
        persistWidgetInterval: (interval) async =>
            widgetPersisted.add(interval),
        observeLifecycle: false,
      );
    }

    setUp(() {
      intervals = StreamController<Duration>.broadcast();
      background = <Duration>[];
      widgetPersisted = <Duration>[];
      publishes = 0;
      samples = 0;
    });

    tearDown(() async {
      await intervals.close();
    });

    test('defaults to 15 minutes and registers background + widget', () {
      fakeAsync((async) {
        final coordinator = buildCoordinator();
        unawaited(coordinator.attach());
        async.flushMicrotasks();

        expect(coordinator.state.interval, const Duration(minutes: 15));
        expect(background, [const Duration(minutes: 15)]);
        expect(widgetPersisted, [const Duration(minutes: 15)]);
        expect(coordinator.activePublishTimerCount, 1);
        coordinator.dispose();
      });
    });

    test('reschedules after changing 15 minutes to 1 minute', () {
      fakeAsync((async) {
        final coordinator = buildCoordinator();
        unawaited(coordinator.attach());
        async.flushMicrotasks();

        unawaited(coordinator.applyInterval(const Duration(minutes: 1)));
        async.flushMicrotasks();

        expect(coordinator.state.interval, const Duration(minutes: 1));
        expect(background.last, const Duration(minutes: 1));
        expect(widgetPersisted.last, const Duration(minutes: 1));
        expect(coordinator.activePublishTimerCount, 1);

        async.elapse(const Duration(minutes: 1));
        expect(publishes, 1);
        coordinator.dispose();
      });
    });

    test('reschedules after changing to 1 hour and 24 hours', () {
      fakeAsync((async) {
        final coordinator = buildCoordinator();
        unawaited(coordinator.attach());
        async.flushMicrotasks();

        unawaited(coordinator.applyInterval(const Duration(hours: 1)));
        async.flushMicrotasks();
        expect(background.last, const Duration(hours: 1));

        unawaited(coordinator.applyInterval(const Duration(hours: 24)));
        async.flushMicrotasks();
        expect(background.last, const Duration(hours: 24));
        expect(widgetPersisted.last, const Duration(hours: 24));
        expect(coordinator.activePublishTimerCount, 1);
        coordinator.dispose();
      });
    });

    test('does not create duplicate publish timers', () {
      fakeAsync((async) {
        final coordinator = buildCoordinator();
        unawaited(coordinator.attach());
        async.flushMicrotasks();
        unawaited(coordinator.applyInterval(const Duration(minutes: 5)));
        async.flushMicrotasks();
        unawaited(coordinator.applyInterval(const Duration(minutes: 5)));
        async.flushMicrotasks();

        expect(coordinator.activePublishTimerCount, 1);

        async.elapse(const Duration(minutes: 5));
        expect(publishes, 1);
        coordinator.dispose();
      });
    });

    test('manual recordSuccessfulUpdate does not change the interval', () {
      fakeAsync((async) {
        final coordinator = buildCoordinator();
        unawaited(coordinator.attach());
        async.flushMicrotasks();

        coordinator.recordSuccessfulUpdate(
          at: DateTime(2026, 1, 1, 12),
        );
        expect(coordinator.state.interval, const Duration(minutes: 15));
        expect(coordinator.activePublishTimerCount, 1);

        async.elapse(const Duration(minutes: 14));
        expect(publishes, 0);
        coordinator.dispose();
      });
    });

    test('samples indoor locally more often than a 24-hour publish', () {
      fakeAsync((async) {
        final coordinator = buildCoordinator();
        unawaited(coordinator.attach());
        async.flushMicrotasks();
        unawaited(coordinator.applyInterval(const Duration(hours: 24)));
        async
          ..flushMicrotasks()
          ..elapse(const Duration(minutes: 2));
        expect(samples, 1);
        expect(publishes, 0);
        coordinator.dispose();
      });
    });
  });
}
