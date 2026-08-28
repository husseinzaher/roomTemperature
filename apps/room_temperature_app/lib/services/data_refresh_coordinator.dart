import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:settings_domain/settings_domain.dart';

/// Snapshot of the global refresh scheduler, for debug UI.
class DataRefreshState {
  /// Creates a refresh-state snapshot.
  const DataRefreshState({
    required this.interval,
    this.lastSuccessfulUpdate,
    this.lastIndoorUpdate,
    this.lastOutdoorUpdate,
    this.nextExpectedUpdate,
    this.foregroundSchedulerActive = false,
    this.backgroundSchedulerConfigured = false,
  });

  /// The user-configured publish interval.
  final Duration interval;

  /// When indoor+outdoor publish last succeeded (or indoor-only).
  final DateTime? lastSuccessfulUpdate;

  /// When indoor was last calculated.
  final DateTime? lastIndoorUpdate;

  /// When outdoor weather last succeeded.
  final DateTime? lastOutdoorUpdate;

  /// lastSuccessfulUpdate + [interval], if known.
  final DateTime? nextExpectedUpdate;

  /// Whether the in-app periodic timer is running.
  final bool foregroundSchedulerActive;

  /// Whether WorkManager was asked to run at the Android-capped frequency.
  final bool backgroundSchedulerConfigured;

  /// Human-readable debug dump.
  String debugSummary() {
    final background = RefreshInterval.backgroundFrequency(interval);
    final foreground = foregroundSchedulerActive ? 'active' : 'paused';
    final backgroundStatus = backgroundSchedulerConfigured
        ? 'configured'
        : 'unconfigured';
    final backgroundLabel = RefreshInterval.debugLabel(background);
    final backgroundLine =
        'Background scheduler: $backgroundStatus ($backgroundLabel; '
        'Android periodic min 15 min)';
    return [
      'Configured interval: ${RefreshInterval.debugLabel(interval)}',
      'Foreground scheduler: $foreground',
      backgroundLine,
      'Widget: configured (pushed from refresh; XML period 0)',
      'Last update: ${lastSuccessfulUpdate ?? '—'}',
      'Next expected update: ${nextExpectedUpdate ?? '—'}',
      'Indoor calculation: local',
      'Network required for indoor: false',
    ].join('\n');
  }
}

/// One foreground refresh scheduler for the app.
///
/// Cancels the previous [Timer] before creating a new one. Background
/// WorkManager is rescheduled through [rescheduleBackground]; the widget
/// stores the same interval via [persistWidgetInterval].
class DataRefreshCoordinator extends ChangeNotifier
    with WidgetsBindingObserver {
  /// Creates a coordinator. Call [attach] once from the home shell.
  DataRefreshCoordinator({
    required this.readInterval,
    required this.intervalChanges,
    required this.publishRefresh,
    required this.sampleIndoor,
    required this.rescheduleBackground,
    required this.persistWidgetInterval,
    DateTime Function()? clock,
    this.observeLifecycle = true,
  }) : _clock = clock ?? DateTime.now;

  /// Current persisted interval.
  final Duration Function() readInterval;

  /// Emits whenever the user changes the interval.
  final Stream<Duration> intervalChanges;

  /// User-facing refresh (indoor + outdoor + widget via cubit).
  final Future<void> Function() publishRefresh;

  /// Lightweight local thermal sample; no weather, no widget.
  final Future<void> Function() sampleIndoor;

  /// Re-register Android WorkManager at the given interval
  /// (platform-capped inside).
  final Future<void> Function(Duration interval) rescheduleBackground;

  /// Persist minutes for the home-screen widget to read.
  final Future<void> Function(Duration interval) persistWidgetInterval;

  /// When false, skip [WidgetsBindingObserver] (unit tests).
  final bool observeLifecycle;

  final DateTime Function() _clock;

  StreamSubscription<Duration>? _intervalSub;
  Timer? _publishTimer;
  Timer? _sampleTimer;
  Duration _interval = RefreshInterval.defaultInterval;
  bool _attached = false;
  bool _foregroundActive = false;
  bool _backgroundConfigured = false;
  DateTime? _lastSuccessfulUpdate;
  DateTime? _lastIndoorUpdate;
  DateTime? _lastOutdoorUpdate;
  int _publishTimerGeneration = 0;

  /// Current debug snapshot.
  DataRefreshState get state => DataRefreshState(
    interval: _interval,
    lastSuccessfulUpdate: _lastSuccessfulUpdate,
    lastIndoorUpdate: _lastIndoorUpdate,
    lastOutdoorUpdate: _lastOutdoorUpdate,
    nextExpectedUpdate: _lastSuccessfulUpdate?.add(_interval),
    foregroundSchedulerActive: _foregroundActive,
    backgroundSchedulerConfigured: _backgroundConfigured,
  );

  /// How many publish timers are currently scheduled (0 or 1).
  int get activePublishTimerCount => _publishTimer == null ? 0 : 1;

  /// Subscribe to settings, start timers, register background work.
  ///
  /// Call once from the home shell after cubits are available.
  Future<void> attach() async {
    if (_attached) {
      return;
    }
    _attached = true;
    if (observeLifecycle) {
      WidgetsBinding.instance.addObserver(this);
    }
    _intervalSub = intervalChanges.listen((interval) {
      unawaited(applyInterval(interval));
    });
    await applyInterval(readInterval());
    await _refreshIfStale();
  }

  /// Records a cached reading without restarting timers.
  void seedLastUpdate(DateTime? at, {bool hasWeather = false}) {
    if (at == null) {
      return;
    }
    _lastSuccessfulUpdate = at;
    _lastIndoorUpdate = at;
    if (hasWeather) {
      _lastOutdoorUpdate = at;
    }
  }

  /// Persist + reschedule every scheduler to [requested].
  Future<void> applyInterval(Duration requested) async {
    final next = RefreshInterval.clamp(requested);
    if (next == _interval &&
        _backgroundConfigured &&
        _publishTimer != null) {
      return;
    }
    _interval = next;
    await persistWidgetInterval(next);
    await rescheduleBackground(next);
    _backgroundConfigured = true;
    _restartForegroundTimers();
    notifyListeners();
  }

  /// Called after a user-facing refresh (manual or scheduled).
  void recordSuccessfulUpdate({
    DateTime? at,
    bool indoor = true,
    bool outdoor = false,
  }) {
    final now = at ?? _clock();
    _lastSuccessfulUpdate = now;
    if (indoor) {
      _lastIndoorUpdate = now;
    }
    if (outdoor) {
      _lastOutdoorUpdate = now;
    }
    _restartPublishTimer();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _restartForegroundTimers();
        unawaited(_refreshIfStale());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _cancelTimers();
        _foregroundActive = false;
        notifyListeners();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    if (_attached && observeLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
    unawaited(_intervalSub?.cancel());
    _cancelTimers();
    super.dispose();
  }

  void _restartForegroundTimers() {
    _cancelTimers();
    _startPublishTimer();
    _startSampleTimer();
    _foregroundActive = true;
  }

  void _restartPublishTimer() {
    _publishTimer?.cancel();
    _publishTimer = null;
    _startPublishTimer();
  }

  void _startPublishTimer() {
    _publishTimerGeneration++;
    final generation = _publishTimerGeneration;
    _publishTimer = Timer.periodic(_interval, (_) {
      if (generation != _publishTimerGeneration) {
        return;
      }
      unawaited(publishRefresh());
    });
  }

  void _startSampleTimer() {
    final sampleEvery = RefreshInterval.internalSampleInterval(_interval);
    if (sampleEvery >= _interval) {
      return;
    }
    _sampleTimer = Timer.periodic(sampleEvery, (_) {
      unawaited(sampleIndoor());
    });
  }

  void _cancelTimers() {
    _publishTimerGeneration++;
    _publishTimer?.cancel();
    _publishTimer = null;
    _sampleTimer?.cancel();
    _sampleTimer = null;
  }

  Future<void> _refreshIfStale() async {
    final last = _lastSuccessfulUpdate;
    if (last == null) {
      return;
    }
    if (_clock().difference(last) >= _interval) {
      await publishRefresh();
    }
  }
}
