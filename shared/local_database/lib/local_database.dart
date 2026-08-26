/// Local database: the Drift (SQLite) store for readings, daily averages,
/// and settings.
library;

export 'package:drift/drift.dart' show QueryExecutor;

export 'src/app_database.dart'
    show
        $DailyAveragesTable,
        $ReadingsTable,
        $SettingsRowsTable,
        AppDatabase,
        DailyAverageRow,
        DailyAveragesCompanion,
        ReadingRow,
        ReadingsCompanion,
        SettingRow,
        SettingsRowsCompanion;
