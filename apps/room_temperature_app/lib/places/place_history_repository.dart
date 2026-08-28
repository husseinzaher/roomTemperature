import 'package:local_database/local_database.dart';
import 'package:room_temperature_app/places/place_models.dart';
import 'package:room_temperature_app/places/visit_detector.dart';
import 'package:room_temperature_app/places/visit_rules.dart';

/// {@template place_history_repository}
/// Local-only place/visit persistence on [AppDatabase].
///
/// Never sends coordinates, visits, or indoor history to a remote API.
/// {@endtemplate}
class PlaceHistoryRepository {
  /// {@macro place_history_repository}
  PlaceHistoryRepository({
    required AppDatabase database,
    VisitDetector detector = const VisitDetector(),
    Future<String?> Function(double latitude, double longitude)? lookupName,
  }) : _database = database,
       _detector = detector,
       _lookupName = lookupName;

  final AppDatabase _database;
  final VisitDetector _detector;
  final Future<String?> Function(double latitude, double longitude)?
  _lookupName;

  /// Fallback label when reverse geocoding is unavailable.
  static const String unnamedPlace = 'Unnamed place';

  /// Applies one location+indoor sample. No-op when [enabled] is false.
  Future<void> observe({
    required bool enabled,
    required double latitude,
    required double longitude,
    required DateTime at,
    required double? indoorCelsius,
  }) async {
    if (!enabled) {
      return;
    }

    final current = await _loadOpenVisit();
    final tick = _detector.observe(
      current: current,
      fix: LocationFix(
        latitude: latitude,
        longitude: longitude,
        at: at,
        indoorCelsius: indoorCelsius,
      ),
    );
    await _applyTick(tick, previous: current);
  }

  /// Closes the open visit if tracking is turned off.
  Future<void> stopTracking() async {
    final current = await _loadOpenVisit();
    if (current == null) {
      return;
    }
    await _applyTick(_detector.close(current: current), previous: current);
  }

  /// Places with aggregated closed-visit stats, most recently visited first.
  Future<List<PlaceSummary>> listPlaces() async {
    final places = await _database.readPlaces();
    final summaries = <PlaceSummary>[];
    for (final place in places) {
      final visits = await _database.readClosedVisits(place.id);
      if (visits.isEmpty) {
        continue;
      }
      summaries.add(_summarize(place, visits));
    }
    summaries.sort((a, b) {
      final aAt = a.lastVisitAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bAt = b.lastVisitAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bAt.compareTo(aAt);
    });
    return summaries;
  }

  /// Closed visits for [placeId], newest first.
  Future<List<PlaceVisitSummary>> listVisits(int placeId) async {
    final rows = await _database.readClosedVisits(placeId);
    return [for (final row in rows) _visitSummary(row)];
  }

  /// Aggregated stats for [placeId], or `null` if missing.
  Future<PlaceSummary?> readPlace(int placeId) async {
    final place = await _database.readPlace(placeId);
    if (place == null) {
      return null;
    }
    final visits = await _database.readClosedVisits(placeId);
    if (visits.isEmpty) {
      return null;
    }
    return _summarize(place, visits);
  }

  /// Deletes one place and its visits.
  Future<void> deletePlace(int placeId) => _database.deletePlace(placeId);

  /// Deletes all places and visits. Does not touch readings or settings.
  Future<void> deleteAll() => _database.deleteAllPlaceHistory();

  Future<OpenVisit?> _loadOpenVisit() async {
    final row = await _database.readOpenVisit();
    if (row == null) {
      return null;
    }
    return OpenVisit(
      id: row.id,
      placeId: row.placeId,
      latitude: row.latitude,
      longitude: row.longitude,
      startedAt: row.startedAt,
      lastSeenAt: row.lastSeenAt,
      stats: IndoorSampleStats(
        sum: row.sumIndoorC,
        min: row.minIndoorC,
        max: row.maxIndoorC,
        count: row.sampleCount,
      ),
    );
  }

  Future<void> _applyTick(
    VisitTick tick, {
    required OpenVisit? previous,
  }) async {
    if (tick.completed != null) {
      await _persistCompleted(tick.completed!, visitId: previous?.id);
    } else if (tick.discardedShortStay && previous?.id != null) {
      await _database.deleteVisit(previous!.id!);
    }

    final open = tick.open;
    if (open == null) {
      return;
    }
    if (open.id != null) {
      await _database.updateOpenVisit(
        visitId: open.id!,
        lastSeenAt: open.lastSeenAt,
        sumIndoorC: open.stats.sum,
        minIndoorC: open.stats.min,
        maxIndoorC: open.stats.max,
        sampleCount: open.stats.count,
      );
      return;
    }
    if (previous != null &&
        previous.id != null &&
        !tick.discardedShortStay &&
        tick.completed == null) {
      await _database.updateOpenVisit(
        visitId: previous.id!,
        lastSeenAt: open.lastSeenAt,
        sumIndoorC: open.stats.sum,
        minIndoorC: open.stats.min,
        maxIndoorC: open.stats.max,
        sampleCount: open.stats.count,
      );
      return;
    }
    await _database.insertOpenVisit(
      latitude: open.latitude,
      longitude: open.longitude,
      startedAt: open.startedAt,
      lastSeenAt: open.lastSeenAt,
      indoorCelsius: open.stats.count == 1 ? open.stats.average : null,
    );
    if (open.stats.count > 1) {
      final stored = await _database.readOpenVisit();
      if (stored != null) {
        await _database.updateOpenVisit(
          visitId: stored.id,
          lastSeenAt: open.lastSeenAt,
          sumIndoorC: open.stats.sum,
          minIndoorC: open.stats.min,
          maxIndoorC: open.stats.max,
          sampleCount: open.stats.count,
        );
      }
    }
  }

  Future<void> _persistCompleted(
    CompletedVisitDraft draft, {
    required int? visitId,
  }) async {
    final placeId = await _findOrCreatePlace(draft);
    final durationSeconds = draft.duration.inSeconds;
    if (visitId != null) {
      await _database.closeVisit(
        visitId: visitId,
        placeId: placeId,
        endedAt: draft.endedAt,
        durationSeconds: durationSeconds,
        sumIndoorC: draft.stats.sum,
        minIndoorC: draft.stats.min,
        maxIndoorC: draft.stats.max,
        sampleCount: draft.stats.count,
      );
      return;
    }
    final id = await _database.insertOpenVisit(
      latitude: draft.latitude,
      longitude: draft.longitude,
      startedAt: draft.startedAt,
      lastSeenAt: draft.endedAt,
      indoorCelsius: null,
    );
    await _database.closeVisit(
      visitId: id,
      placeId: placeId,
      endedAt: draft.endedAt,
      durationSeconds: durationSeconds,
      sumIndoorC: draft.stats.sum,
      minIndoorC: draft.stats.min,
      maxIndoorC: draft.stats.max,
      sampleCount: draft.stats.count,
    );
  }

  Future<int> _findOrCreatePlace(CompletedVisitDraft draft) async {
    if (draft.placeId != null) {
      return draft.placeId!;
    }
    final existing = await _database.readPlaces();
    for (final place in existing) {
      final meters = VisitDetector.distanceMeters(
        place.latitude,
        place.longitude,
        draft.latitude,
        draft.longitude,
      );
      if (meters <= VisitRules.groupingRadiusMeters) {
        return place.id;
      }
    }
    var name = unnamedPlace;
    String? address;
    final lookup = _lookupName;
    if (lookup != null) {
      try {
        final resolved = await lookup(draft.latitude, draft.longitude);
        if (resolved != null && resolved.trim().isNotEmpty) {
          name = resolved.trim();
        }
      } on Object {
        // Offline geocoding must not block storing the visit.
      }
    }
    return _database.insertPlace(
      latitude: draft.latitude,
      longitude: draft.longitude,
      name: name,
      address: address,
      createdAt: draft.startedAt,
    );
  }

  PlaceSummary _summarize(PlaceRow place, List<PlaceVisitRow> visits) {
    var sum = 0.0;
    var count = 0;
    double? min;
    double? max;
    var durationSeconds = 0;
    DateTime? lastVisitAt;
    for (final visit in visits) {
      durationSeconds += visit.durationSeconds;
      count += visit.sampleCount;
      sum += visit.sumIndoorC;
      if (visit.minIndoorC != null) {
        min = min == null
            ? visit.minIndoorC
            : (visit.minIndoorC! < min ? visit.minIndoorC : min);
      }
      if (visit.maxIndoorC != null) {
        max = max == null
            ? visit.maxIndoorC
            : (visit.maxIndoorC! > max ? visit.maxIndoorC : max);
      }
      final ended = visit.endedAt;
      if (ended != null &&
          (lastVisitAt == null || ended.isAfter(lastVisitAt))) {
        lastVisitAt = ended;
      }
    }
    return PlaceSummary(
      id: place.id,
      latitude: place.latitude,
      longitude: place.longitude,
      name: place.name,
      address: place.address,
      visitCount: visits.length,
      totalDuration: Duration(seconds: durationSeconds),
      averageIndoorCelsius: count == 0 ? null : sum / count,
      minIndoorCelsius: min,
      maxIndoorCelsius: max,
      lastVisitAt: lastVisitAt,
    );
  }

  PlaceVisitSummary _visitSummary(PlaceVisitRow row) {
    return PlaceVisitSummary(
      id: row.id,
      startedAt: row.startedAt,
      endedAt: row.endedAt ?? row.lastSeenAt,
      duration: Duration(seconds: row.durationSeconds),
      sampleCount: row.sampleCount,
      averageIndoorCelsius: row.sampleCount == 0
          ? null
          : row.sumIndoorC / row.sampleCount,
      minIndoorCelsius: row.minIndoorC,
      maxIndoorCelsius: row.maxIndoorC,
    );
  }
}
