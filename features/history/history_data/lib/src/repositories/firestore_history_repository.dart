import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:history_data/src/converters/daily_average_converter.dart';
import 'package:history_domain/history_domain.dart';

/// {@template firestore_history_repository}
/// An [IHistoryRepository] backed by Cloud Firestore.
///
/// Daily averages are stored under `users/{userId}/dailyAverages/{isoDateKey}`,
/// one document per calendar day, holding running sums and a sample count
/// rather than pre-computed averages — see [DailyAverageConverter].
/// {@endtemplate}
class FirestoreHistoryRepository implements IHistoryRepository {
  /// {@macro firestore_history_repository}
  FirestoreHistoryRepository({
    FirebaseFirestore? firestore,
    this._converter = const DailyAverageConverter(),
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final DailyAverageConverter _converter;

  CollectionReference<Map<String, dynamic>> _dailyAveragesCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('dailyAverages');
  }

  /// Computes the `isoDateKey`-formatted document id for [day], reusing
  /// [DailyAverage.isoDateKey] so the format can never drift from the
  /// domain model's own formatting logic.
  String _isoDateKey(DateTime day) {
    return DailyAverage(
      day: day,
      averageRoomTemperatureCelsius: 0,
      averageOutsideTemperatureCelsius: 0,
      sampleCount: 0,
    ).isoDateKey;
  }

  @override
  Stream<List<DailyAverage>> watchHistory({
    required String userId,
    int days = 30,
  }) {
    return _dailyAveragesCollection(
      userId,
    ).orderBy('day', descending: true).limit(days).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => _converter.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<void> recordSample({
    required String userId,
    required DateTime day,
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
  }) async {
    final docRef = _dailyAveragesCollection(userId).doc(_isoDateKey(day));
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          'day': Timestamp.fromDate(normalizedDay),
          'sumRoomTempC': roomTemperatureCelsius,
          'sumOutsideTempC': outsideTemperatureCelsius,
          'sampleCount': 1,
        });
      } else {
        transaction.update(
          docRef,
          _converter.toFirestoreUpdate(
            addRoomTempC: roomTemperatureCelsius,
            addOutsideTempC: outsideTemperatureCelsius,
          ),
        );
      }
    });
  }
}
