import 'package:drift/drift.dart';

/// {@template places_table}
/// A locally stored geographic place that groups nearby [PlaceVisits].
///
/// Coordinates never leave the device. Reverse-geocoded names are cached
/// here so later visits stay usable offline.
/// {@endtemplate}
@DataClassName('PlaceRow')
class Places extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Visit-cluster latitude, in degrees.
  RealColumn get latitude => real()();

  /// Visit-cluster longitude, in degrees.
  RealColumn get longitude => real()();

  /// Cached human-readable name, e.g. `Nasr City`.
  TextColumn get name => text()();

  /// Optional longer address from reverse geocoding.
  TextColumn get address => text().nullable()();

  /// When this place cluster was first created.
  DateTimeColumn get createdAt => dateTime()();
}
