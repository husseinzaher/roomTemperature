import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:history_domain/history_domain.dart';

/// {@template daily_average_converter}
/// Converts between the domain [DailyAverage] model and the raw Firestore
/// running-sum document shape stored under
/// `users/{userId}/dailyAverages/{isoDateKey}`.
///
/// Per FFCA data-layer guidance, this is the single place where the raw
/// Firestore sum/count shape is translated to and from the domain model —
/// both averages are always computed here as `sum / sampleCount`, never
/// stored pre-computed, so this converter is the single source of truth for
/// that computation.
/// {@endtemplate}
class DailyAverageConverter {
  /// {@macro daily_average_converter}
  const DailyAverageConverter();

  /// Converts a raw Firestore document [data] map (with document id
  /// [docId]) to a domain [DailyAverage], computing both averages from the
  /// stored sums and sample count.
  ///
  /// The day is read from the `day` timestamp field; if that field is
  /// missing, [docId] (an `isoDateKey`-formatted date) is parsed instead.
  DailyAverage fromFirestore(String docId, Map<String, dynamic> data) {
    final sumRoomTempC = (data['sumRoomTempC'] as num).toDouble();
    final sumOutsideTempC = (data['sumOutsideTempC'] as num).toDouble();
    final sampleCount = data['sampleCount'] as int;
    final dayTimestamp = data['day'] as Timestamp?;
    final day = dayTimestamp?.toDate() ?? _dayFromDocId(docId);

    return DailyAverage(
      day: day,
      averageRoomTemperatureCelsius: sumRoomTempC / sampleCount,
      averageOutsideTemperatureCelsius: sumOutsideTempC / sampleCount,
      sampleCount: sampleCount,
    );
  }

  /// Returns a map suitable for a Firestore transaction's incremental
  /// update of an *existing* daily average document — incrementing the
  /// running sums and sample count by one new sample.
  ///
  /// This is only used when the document already exists; the caller is
  /// responsible for creating the document (including its `day` field) the
  /// first time a sample is recorded for a given day.
  Map<String, dynamic> toFirestoreUpdate({
    required double addRoomTempC,
    required double addOutsideTempC,
  }) {
    return {
      'sumRoomTempC': FieldValue.increment(addRoomTempC),
      'sumOutsideTempC': FieldValue.increment(addOutsideTempC),
      'sampleCount': FieldValue.increment(1),
    };
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
