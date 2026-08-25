import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:settings_data/src/converters/user_settings_converter.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template firestore_settings_repository}
/// A [ISettingsRepository] implementation backed by Cloud Firestore, with an
/// optional local cache for an instant cache-then-network read.
///
/// Settings live as five top-level fields on the `users/{userId}` profile
/// document, a document also written to by other features (e.g.
/// notifications' `fcmToken`). Every write therefore uses a merge-write
/// (`SetOptions(merge: true)`) so this repository never clobbers fields it
/// does not own.
///
/// When [localCache] is supplied, [watchSettings] first synchronously emits
/// whatever is cached (if anything) so the UI never has to show a blank
/// loading state on a warm start, then keeps emitting live Firestore
/// snapshots as they arrive. Each live snapshot is written back to the
/// cache so the next cold start has fresh data available immediately.
/// {@endtemplate}
class FirestoreSettingsRepository implements ISettingsRepository {
  /// {@macro firestore_settings_repository}
  FirestoreSettingsRepository({
    FirebaseFirestore? firestore,
    this.localCache,
    this._converter = const UserSettingsConverter(),
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// The Firestore collection holding user profile documents.
  static const String usersCollection = 'users';

  /// The local cache key prefix. The full key is `'$_cacheKeyPrefix$userId'`.
  static const String _cacheKeyPrefix = 'settings_cache_';

  final FirebaseFirestore _firestore;
  final UserSettingsConverter _converter;

  /// The optional local cache used for an instant cache-then-network read.
  final SharedPreferences? localCache;

  @override
  Stream<UserSettings> watchSettings({required String userId}) async* {
    final cache = localCache;
    if (cache != null) {
      final cached = _readCache(cache, userId);
      if (cached != null) yield cached;
    }

    yield* _firestore.collection(usersCollection).doc(userId).snapshots().map((
      snapshot,
    ) {
      final settings = _converter.fromMap(snapshot.data() ?? const {});
      if (cache != null) _writeCache(cache, userId, settings);
      return settings;
    });
  }

  @override
  Future<void> updateSettings({
    required String userId,
    required UserSettings settings,
  }) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .set(_converter.toMap(settings), SetOptions(merge: true));

    final cache = localCache;
    if (cache != null) _writeCache(cache, userId, settings);
  }

  UserSettings? _readCache(SharedPreferences cache, String userId) {
    final raw = cache.getString('$_cacheKeyPrefix$userId');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return _converter.fromMap(decoded);
    } on FormatException {
      return null;
    }
  }

  void _writeCache(
    SharedPreferences cache,
    String userId,
    UserSettings settings,
  ) {
    unawaited(
      cache.setString(
        '$_cacheKeyPrefix$userId',
        jsonEncode(_converter.toMap(settings)),
      ),
    );
  }
}
