import 'dart:async';
import 'dart:convert';

import 'package:history_data/src/converters/daily_average_converter.dart';
import 'package:history_domain/history_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A local-only [IHistoryRepository] backed by [SharedPreferences].
class LocalHistoryRepository implements IHistoryRepository {
  /// Creates a local history repository.
  LocalHistoryRepository({
    required SharedPreferences sharedPreferences,
    this._converter = const DailyAverageConverter(),
  }) : _sharedPreferences = sharedPreferences;

  static const String _cacheKeyPrefix = 'daily_averages_';

  final SharedPreferences _sharedPreferences;
  final DailyAverageConverter _converter;
  final _controllers = <String, StreamController<List<DailyAverage>>>{};

  @override
  Stream<List<DailyAverage>> watchHistory({
    required String userId,
    int days = 30,
  }) async* {
    yield _readHistory(userId, days: days);
    yield* _controllerFor(
      userId,
    ).stream.map((items) => items.take(days).toList());
  }

  @override
  Future<void> recordSample({
    required String userId,
    required DateTime day,
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
  }) async {
    final data = _readRaw(userId);
    final key = DailyAverage(
      day: day,
      averageRoomTemperatureCelsius: 0,
      averageOutsideTemperatureCelsius: 0,
      sampleCount: 0,
    ).isoDateKey;

    data[key] = _converter.addSample(
      current: data[key],
      addRoomTempC: roomTemperatureCelsius,
      addOutsideTempC: outsideTemperatureCelsius,
    );

    await _sharedPreferences.setString(
      '$_cacheKeyPrefix$userId',
      jsonEncode(data),
    );
    _controllerFor(userId).add(_readHistory(userId));
  }

  Map<String, Map<String, dynamic>> _readRaw(String userId) {
    final raw = _sharedPreferences.getString('$_cacheKeyPrefix$userId');
    if (raw == null) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return decoded.map((key, value) {
        if (value is Map<String, dynamic>) return MapEntry(key, value);
        return MapEntry(key, <String, dynamic>{});
      });
    } on FormatException {
      return {};
    }
  }

  List<DailyAverage> _readHistory(String userId, {int days = 30}) {
    final data = _readRaw(userId);
    final items =
        data.entries
            .where((entry) => entry.value.isNotEmpty)
            .map((entry) => _converter.fromMap(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.day.compareTo(a.day));
    return items.take(days).toList();
  }

  StreamController<List<DailyAverage>> _controllerFor(String userId) {
    return _controllers.putIfAbsent(
      userId,
      () => StreamController<List<DailyAverage>>.broadcast(),
    );
  }
}
