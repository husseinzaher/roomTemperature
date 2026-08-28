import 'dart:convert';

import 'package:local_database/local_database.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template weather_cache_store}
/// Persists the last successful [OutsideWeather] (including 5-day forecast)
/// in the existing settings key/value table so widgets and the dashboard
/// can render offline.
/// {@endtemplate}
class WeatherCacheStore {
  /// {@macro weather_cache_store}
  const WeatherCacheStore(this._database);

  final AppDatabase _database;

  /// JSON payload of the last successful weather fetch.
  static const String jsonKey = 'cachedWeatherJson';

  /// ISO-8601 timestamp of that fetch.
  static const String atKey = 'cachedWeatherAt';

  /// Writes [weather] and [at] (defaults to now).
  Future<void> save(OutsideWeather weather, {DateTime? at}) {
    final timestamp = (at ?? DateTime.now()).toUtc().toIso8601String();
    return _database.writeSettings({
      jsonKey: jsonEncode(weather.toJson()),
      atKey: timestamp,
    });
  }

  /// Returns the cached weather, or `null` when missing or corrupt.
  Future<OutsideWeather?> load() async {
    final raw = await _database.readSetting(jsonKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return OutsideWeather.tryFromJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  /// When the cache was last written, or `null`.
  Future<DateTime?> loadedAt() async {
    final raw = await _database.readSetting(atKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
