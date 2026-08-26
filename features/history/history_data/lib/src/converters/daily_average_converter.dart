import 'package:history_domain/history_domain.dart';

/// {@template daily_average_converter}
/// Converts between [DailyAverage] and the local running-sum map shape.
/// {@endtemplate}
class DailyAverageConverter {
  /// {@macro daily_average_converter}
  const DailyAverageConverter();

  /// Converts a raw local [data] map (with document id
  /// [docId]) to a domain [DailyAverage], computing both averages from the
  /// stored sums and sample count.
  DailyAverage fromMap(String docId, Map<String, dynamic> data) {
    final sumRoomTempC = (data['sumRoomTempC'] as num).toDouble();
    final sumOutsideTempC = (data['sumOutsideTempC'] as num).toDouble();
    final sampleCount = data['sampleCount'] as int;

    return DailyAverage(
      day: _dayFromDocId(docId),
      averageRoomTemperatureCelsius: sumRoomTempC / sampleCount,
      averageOutsideTemperatureCelsius: sumOutsideTempC / sampleCount,
      sampleCount: sampleCount,
    );
  }

  /// Returns the local running-sum map for a daily average.
  Map<String, dynamic> toMap({
    required double sumRoomTempC,
    required double sumOutsideTempC,
    required int sampleCount,
  }) {
    return {
      'sumRoomTempC': sumRoomTempC,
      'sumOutsideTempC': sumOutsideTempC,
      'sampleCount': sampleCount,
    };
  }

  /// Returns the updated local running-sum map for one new sample.
  Map<String, dynamic> addSample({
    required Map<String, dynamic>? current,
    required double addRoomTempC,
    required double addOutsideTempC,
  }) {
    final sumRoomTempC = (current?['sumRoomTempC'] as num?)?.toDouble() ?? 0;
    final sumOutsideTempC =
        (current?['sumOutsideTempC'] as num?)?.toDouble() ?? 0;
    final sampleCount = current?['sampleCount'] as int? ?? 0;

    return toMap(
      sumRoomTempC: sumRoomTempC + addRoomTempC,
      sumOutsideTempC: sumOutsideTempC + addOutsideTempC,
      sampleCount: sampleCount + 1,
    );
  }

  DateTime _dayFromDocId(String docId) {
    final parts = docId.split('-');
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
