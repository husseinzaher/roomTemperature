import 'package:equatable/equatable.dart';

/// {@template location}
/// A geographic coordinate used to fetch the outside temperature.
/// {@endtemplate}
class Location extends Equatable {
  /// {@macro location}
  const Location({required this.latitude, required this.longitude});

  /// The latitude in decimal degrees.
  final double latitude;

  /// The longitude in decimal degrees.
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
