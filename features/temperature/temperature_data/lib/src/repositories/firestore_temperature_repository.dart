import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temperature_data/src/converters/reading_converter.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template firestore_temperature_repository}
/// An [ITemperatureRepository] backed by Cloud Firestore.
///
/// Readings are stored under `users/{userId}/readings/{autoId}`.
/// {@endtemplate}
class FirestoreTemperatureRepository implements ITemperatureRepository {
  /// {@macro firestore_temperature_repository}
  FirestoreTemperatureRepository({
    FirebaseFirestore? firestore,
    this._converter = const ReadingConverter(),
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final ReadingConverter _converter;

  CollectionReference<Map<String, dynamic>> _readingsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('readings');
  }

  @override
  Future<void> recordReading({
    required String userId,
    required Reading reading,
  }) async {
    await _readingsCollection(userId).add(_converter.toFirestore(reading));
  }

  @override
  Stream<Reading?> watchLatestReading({required String userId}) {
    return _readingsCollection(userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          return _converter.fromFirestore(snapshot.docs.first.data());
        });
  }
}
