import 'dart:math' as math;

import 'package:room_temperature_app/places/visit_rules.dart';

/// Running indoor stats for one visit, from valid estimator samples only.
class IndoorSampleStats {
  /// Creates indoor sample stats.
  const IndoorSampleStats({
    this.sum = 0,
    this.min,
    this.max,
    this.count = 0,
  });

  /// Empty stats (no samples yet).
  static const IndoorSampleStats empty = IndoorSampleStats();

  /// Sum of valid indoor °C samples.
  final double sum;

  /// Lowest valid sample, if any.
  final double? min;

  /// Highest valid sample, if any.
  final double? max;

  /// Number of valid samples.
  final int count;

  /// Mean of valid samples, or `null` when [count] is 0.
  double? get average => count == 0 ? null : sum / count;

  /// Returns a copy with [celsius] folded in.
  IndoorSampleStats add(double celsius) {
    return IndoorSampleStats(
      sum: sum + celsius,
      min: min == null ? celsius : math.min(min!, celsius),
      max: max == null ? celsius : math.max(max!, celsius),
      count: count + 1,
    );
  }
}

/// One GPS + indoor sample used by [VisitDetector].
class LocationFix {
  /// Creates a location fix.
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.at,
    this.indoorCelsius,
  });

  /// Degrees latitude.
  final double latitude;

  /// Degrees longitude.
  final double longitude;

  /// When this sample was taken.
  final DateTime at;

  /// Local indoor estimate in °C, if one was produced.
  final double? indoorCelsius;
}

/// An in-progress dwell that has not yet been closed.
class OpenVisit {
  /// Creates an open visit.
  const OpenVisit({
    required this.latitude,
    required this.longitude,
    required this.startedAt,
    required this.lastSeenAt,
    this.id,
    this.placeId,
    this.stats = IndoorSampleStats.empty,
  });

  /// Database id when already persisted.
  final int? id;

  /// Existing place id when grouped with a known cluster.
  final int? placeId;

  /// Anchor latitude for grouping (first sample).
  final double latitude;

  /// Anchor longitude for grouping (first sample).
  final double longitude;

  /// First sample time.
  final DateTime startedAt;

  /// Most recent sample still inside the grouping radius.
  final DateTime lastSeenAt;

  /// Indoor running stats.
  final IndoorSampleStats stats;

  /// Time spent so far.
  Duration get duration => lastSeenAt.difference(startedAt);

  /// Copy with replaced fields.
  OpenVisit copyWith({
    int? id,
    int? placeId,
    DateTime? lastSeenAt,
    IndoorSampleStats? stats,
  }) {
    return OpenVisit(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      latitude: latitude,
      longitude: longitude,
      startedAt: startedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      stats: stats ?? this.stats,
    );
  }
}

/// A dwell that met [VisitRules.minDwell] and is ready to store.
class CompletedVisitDraft {
  /// Creates a completed visit draft.
  const CompletedVisitDraft({
    required this.latitude,
    required this.longitude,
    required this.startedAt,
    required this.endedAt,
    required this.stats,
    this.placeId,
  });

  /// Existing place to attach to, if already known.
  final int? placeId;

  /// Session latitude.
  final double latitude;

  /// Session longitude.
  final double longitude;

  /// Arrival time.
  final DateTime startedAt;

  /// Departure time (last sample inside the radius).
  final DateTime endedAt;

  /// Indoor running stats.
  final IndoorSampleStats stats;

  /// Dwell duration.
  Duration get duration => endedAt.difference(startedAt);
}

/// Result of feeding one [LocationFix] into [VisitDetector].
class VisitTick {
  /// Creates a visit tick.
  const VisitTick({
    this.open,
    this.completed,
    this.discardedShortStay = false,
  });

  /// Current open visit after this sample.
  final OpenVisit? open;

  /// Visit that just closed and should be persisted.
  final CompletedVisitDraft? completed;

  /// True when a short stay was dropped without saving.
  final bool discardedShortStay;
}

/// Groups nearby location samples into dwell sessions.
///
/// Pure Dart: no GPS, no I/O. The tracker persists [VisitTick] results.
class VisitDetector {
  /// Creates a detector.
  const VisitDetector();

  /// Earth radius used by the haversine grouping check, in meters.
  static const double _earthRadiusMeters = 6371000;

  /// Applies [fix] to [current] and returns the next open/completed state.
  VisitTick observe({
    required OpenVisit? current,
    required LocationFix fix,
  }) {
    final indoor = VisitRules.isValidIndoorCelsius(fix.indoorCelsius)
        ? fix.indoorCelsius
        : null;

    if (current == null) {
      return VisitTick(
        open: _start(fix, indoor),
      );
    }

    final distance = distanceMeters(
      current.latitude,
      current.longitude,
      fix.latitude,
      fix.longitude,
    );
    if (distance <= VisitRules.groupingRadiusMeters) {
      return VisitTick(
        open: current.copyWith(
          lastSeenAt: fix.at,
          stats: indoor == null ? current.stats : current.stats.add(indoor),
        ),
      );
    }

    final closed = _close(current);
    return VisitTick(
      open: _start(fix, indoor),
      completed: closed.completed,
      discardedShortStay: closed.discardedShortStay,
    );
  }

  /// Closes [current] without starting a new visit (e.g. tracking disabled).
  VisitTick close({required OpenVisit current}) {
    return _close(current);
  }

  VisitTick _close(OpenVisit current) {
    final dwell = current.duration;
    final hasSamples = current.stats.count > 0;
    if (dwell >= VisitRules.minDwell && hasSamples) {
      return VisitTick(
        completed: CompletedVisitDraft(
          placeId: current.placeId,
          latitude: current.latitude,
          longitude: current.longitude,
          startedAt: current.startedAt,
          endedAt: current.lastSeenAt,
          stats: current.stats,
        ),
      );
    }
    return const VisitTick(discardedShortStay: true);
  }

  OpenVisit _start(LocationFix fix, double? indoor) {
    return OpenVisit(
      latitude: fix.latitude,
      longitude: fix.longitude,
      startedAt: fix.at,
      lastSeenAt: fix.at,
      stats: indoor == null
          ? IndoorSampleStats.empty
          : IndoorSampleStats.empty.add(indoor),
    );
  }

  /// Great-circle distance in meters between two WGS84 points.
  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * _earthRadiusMeters * math.asin(math.sqrt(a));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
