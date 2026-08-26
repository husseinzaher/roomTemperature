import 'dart:async';
import 'dart:convert';

import 'package:settings_data/src/converters/user_settings_converter.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A local-only [ISettingsRepository] backed by [SharedPreferences].
class LocalSettingsRepository implements ISettingsRepository {
  /// Creates a local settings repository.
  LocalSettingsRepository({
    required SharedPreferences sharedPreferences,
    this._converter = const UserSettingsConverter(),
  }) : _sharedPreferences = sharedPreferences;

  static const String _cacheKeyPrefix = 'settings_cache_';

  final SharedPreferences _sharedPreferences;
  final UserSettingsConverter _converter;
  final _controllers = <String, StreamController<UserSettings>>{};
  final _lastSettings = <String, UserSettings>{};

  /// Returns the most recently read or written settings for [userId].
  UserSettings lastSettingsOrDefault([String userId = 'local-device']) {
    return _lastSettings[userId] ?? _read(userId);
  }

  @override
  Stream<UserSettings> watchSettings({required String userId}) async* {
    yield _read(userId);
    yield* _controllerFor(userId).stream;
  }

  @override
  Future<void> updateSettings({
    required String userId,
    required UserSettings settings,
  }) async {
    await _sharedPreferences.setString(
      '$_cacheKeyPrefix$userId',
      jsonEncode(_converter.toMap(settings)),
    );
    _lastSettings[userId] = settings;
    _controllerFor(userId).add(settings);
  }

  UserSettings _read(String userId) {
    final raw = _sharedPreferences.getString('$_cacheKeyPrefix$userId');
    if (raw == null) return UserSettings.defaults();

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return UserSettings.defaults();
      final settings = _converter.fromMap(decoded);
      _lastSettings[userId] = settings;
      return settings;
    } on FormatException {
      return UserSettings.defaults();
    }
  }

  StreamController<UserSettings> _controllerFor(String userId) {
    return _controllers.putIfAbsent(
      userId,
      () => StreamController<UserSettings>.broadcast(),
    );
  }
}
