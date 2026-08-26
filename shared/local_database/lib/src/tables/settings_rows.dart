import 'package:drift/drift.dart';

/// {@template settings_rows_table}
/// A generic key/value store for user settings.
///
/// Deliberately schemaless: features persist their own keys as strings so a
/// new preference never costs a schema migration, and a key nothing has
/// written yet simply reads back as `null` (meaning "use the default").
/// {@endtemplate}
@DataClassName('SettingRow')
class SettingsRows extends Table {
  /// The setting's key.
  TextColumn get key => text()();

  /// The setting's value, encoded as text by the writing feature.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
