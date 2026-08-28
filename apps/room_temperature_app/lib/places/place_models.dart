import 'package:equatable/equatable.dart';

/// Aggregated stats for one locally stored place (many visits).
class PlaceSummary extends Equatable {
  /// Creates a place summary.
  const PlaceSummary({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.visitCount,
    required this.totalDuration,
    this.address,
    this.averageIndoorCelsius,
    this.minIndoorCelsius,
    this.maxIndoorCelsius,
    this.lastVisitAt,
  });

  /// Place id.
  final int id;

  /// Cluster latitude.
  final double latitude;

  /// Cluster longitude.
  final double longitude;

  /// Cached display name.
  final String name;

  /// Optional cached address.
  final String? address;

  /// Closed visits at this place.
  final int visitCount;

  /// Sum of closed-visit durations.
  final Duration totalDuration;

  /// Sample-weighted mean indoor °C across visits.
  final double? averageIndoorCelsius;

  /// Lowest indoor °C across visits.
  final double? minIndoorCelsius;

  /// Highest indoor °C across visits.
  final double? maxIndoorCelsius;

  /// End of the most recent closed visit.
  final DateTime? lastVisitAt;

  @override
  List<Object?> get props => [
    id,
    latitude,
    longitude,
    name,
    address,
    visitCount,
    totalDuration,
    averageIndoorCelsius,
    minIndoorCelsius,
    maxIndoorCelsius,
    lastVisitAt,
  ];
}

/// One closed visit shown on the place-details screen.
class PlaceVisitSummary extends Equatable {
  /// Creates a visit summary.
  const PlaceVisitSummary({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.sampleCount,
    this.averageIndoorCelsius,
    this.minIndoorCelsius,
    this.maxIndoorCelsius,
  });

  /// Visit id.
  final int id;

  /// Arrival.
  final DateTime startedAt;

  /// Departure.
  final DateTime endedAt;

  /// Time spent.
  final Duration duration;

  /// Valid indoor samples.
  final int sampleCount;

  /// Mean indoor °C for this visit.
  final double? averageIndoorCelsius;

  /// Lowest indoor °C.
  final double? minIndoorCelsius;

  /// Highest indoor °C.
  final double? maxIndoorCelsius;

  @override
  List<Object?> get props => [
    id,
    startedAt,
    endedAt,
    duration,
    sampleCount,
    averageIndoorCelsius,
    minIndoorCelsius,
    maxIndoorCelsius,
  ];
}
