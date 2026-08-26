import 'dart:async';
import 'dart:convert';

import 'package:temperature_data/src/converters/reading_converter.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A local-only [ITemperatureRepository] backed by [SharedPreferences].
class LocalTemperatureRepository implements ITemperatureRepository {
  /// Creates a local temperature repository.
  LocalTemperatureRepository({
    required SharedPreferences sharedPreferences,
    this._converter = const ReadingConverter(),
  }) : _sharedPreferences = sharedPreferences;

  static const String _latestKeyPrefix = 'latest_reading_';

  final SharedPreferences _sharedPreferences;
  final ReadingConverter _converter;
  final _controllers = <String, StreamController<Reading?>>{};

  @override
  Future<void> recordReading({
    required String userId,
    required Reading reading,
  }) async {
    await _sharedPreferences.setString(
      '$_latestKeyPrefix$userId',
      jsonEncode(_converter.toMap(reading)),
    );
    _controllerFor(userId).add(reading);
  }

  @override
  Stream<Reading?> watchLatestReading({required String userId}) async* {
    yield _readLatest(userId);
    yield* _controllerFor(userId).stream;
  }

  Reading? _readLatest(String userId) {
    final raw = _sharedPreferences.getString('$_latestKeyPrefix$userId');
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return _converter.fromMap(decoded);
    } on FormatException {
      return null;
    }
  }

  StreamController<Reading?> _controllerFor(String userId) {
    return _controllers.putIfAbsent(
      userId,
      () => StreamController<Reading?>.broadcast(),
    );
  }
}
