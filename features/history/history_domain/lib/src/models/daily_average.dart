import 'package:equatable/equatable.dart';

/// {@template daily_average}
/// The running daily average of room and outside temperatures for a single
/// calendar day, computed from the periodic `Reading`s recorded by the
/// temperature feature.
///
/// [day] is date-only (no time-of-day component) and is normalized to
/// midnight UTC.
/// {@endtemplate}
class DailyAverage extends Equatable {
  /// {@macro daily_average}
  DailyAverage({
    required DateTime day,
    required this.averageRoomTemperatureCelsius,
    required this.averageOutsideTemperatureCelsius,
    required this.sampleCount,
  }) : day = DateTime.utc(day.year, day.month, day.day);

  /// The calendar day this average covers, normalized to midnight UTC.
  final DateTime day;

  /// The running average room temperature in Celsius for [day].
  final double averageRoomTemperatureCelsius;

  /// The running average outside temperature in Celsius for [day].
  final double averageOutsideTemperatureCelsius;

  /// The number of samples that were folded into this average.
  final int sampleCount;

  /// The ISO `yyyy-MM-dd` representation of [day], used as the stable
  /// display and lookup key for this daily average downstream.
  String get isoDateKey =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
    day,
    averageRoomTemperatureCelsius,
    averageOutsideTemperatureCelsius,
    sampleCount,
  ];
}
