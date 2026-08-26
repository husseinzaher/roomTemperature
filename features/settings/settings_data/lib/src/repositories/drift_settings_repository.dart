import 'package:local_database/local_database.dart';
import 'package:settings_data/src/converters/user_settings_converter.dart';
import 'package:settings_domain/settings_domain.dart';

/// {@template drift_settings_repository}
/// An [ISettingsRepository] backed by the on-device Drift database.
///
/// Every field is stored as its own key/value row, so a write only ever
/// touches the keys this feature owns and leaves any key owned by another
/// feature untouched. Nothing stored yet reads back as
/// [UserSettings.defaults].
/// {@endtemplate}
class DriftSettingsRepository implements ISettingsRepository {
  /// {@macro drift_settings_repository}
  DriftSettingsRepository({
    required AppDatabase database,
    UserSettingsConverter converter = const UserSettingsConverter(),
  }) : _database = database,
       _converter = converter;

  final AppDatabase _database;
  final UserSettingsConverter _converter;

  UserSettings? _lastSettings;

  /// The most recently read or written settings, or [UserSettings.defaults]
  /// before anything has been read.
  ///
  /// This exists for the synchronous callers that cannot await a stream —
  /// notably the indoor-temperature source resolution, which needs the
  /// current offset while building a reading.
  UserSettings lastSettingsOrDefault() =>
      _lastSettings ?? UserSettings.defaults();

  @override
  Stream<UserSettings> watchSettings() {
    return _database.watchSettings().map(_remember);
  }

  @override
  Future<void> updateSettings({required UserSettings settings}) async {
    await _database.writeSettings(_converter.toMap(settings));
    _lastSettings = settings;
  }

  UserSettings _remember(Map<String, String> values) {
    final settings = _converter.fromMap(values);
    _lastSettings = settings;
    return settings;
  }
}
