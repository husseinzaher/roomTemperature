import 'package:drift/drift.dart';
import 'package:local_database/src/tables/places.dart';

/// {@template place_visits_table}
/// One dwell session at a [Places] cluster.
///
/// Open visits have a null [PlaceVisits.endedAt]. Short stays that never
/// meet the dwell threshold are deleted rather than shown in history.
/// Indoor stats are running sums of valid local indoor estimates — never
/// raw battery temperature.
/// {@endtemplate}
@DataClassName('PlaceVisitRow')
@TableIndex(name: 'place_visits_place_id', columns: {#placeId})
class PlaceVisits extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The place this session belongs to. Null while the visit is still open
  /// and has not yet been grouped into a cluster.
  IntColumn get placeId => integer().nullable().references(
    Places,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Session latitude (first sample).
  RealColumn get latitude => real()();

  /// Session longitude (first sample).
  RealColumn get longitude => real()();

  /// When the user arrived (first sample of this dwell).
  DateTimeColumn get startedAt => dateTime()();

  /// Most recent sample still inside the grouping radius.
  DateTimeColumn get lastSeenAt => dateTime()();

  /// When the user left. Null while the visit is still open.
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// Closed-visit duration in seconds. Zero while open.
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();

  /// Running sum of valid indoor °C samples.
  RealColumn get sumIndoorC => real().withDefault(const Constant(0))();

  /// Lowest valid indoor °C, or null before the first sample.
  RealColumn get minIndoorC => real().nullable()();

  /// Highest valid indoor °C, or null before the first sample.
  RealColumn get maxIndoorC => real().nullable()();

  /// Number of valid indoor samples folded into [sumIndoorC].
  IntColumn get sampleCount => integer().withDefault(const Constant(0))();
}
