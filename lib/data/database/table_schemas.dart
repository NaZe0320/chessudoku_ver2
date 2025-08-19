import 'package:chessudoku/core/config/database_config.dart';

/// 데이터베이스 테이블 스키마 정의 클래스
class TableSchemas {
  static const String createDataVersionsTable = '''
    CREATE TABLE ${DatabaseConfig.tableDataVersions} (
      dataType TEXT PRIMARY KEY,
      version INTEGER NOT NULL,
      updatedAt TEXT NOT NULL
    )
  ''';

  static const String createLanguagePacksTable = '''
    CREATE TABLE ${DatabaseConfig.tableLanguagePacks} (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      nativeName TEXT NOT NULL,
      languageCode TEXT NOT NULL,
      countryCode TEXT NOT NULL,
      isDownloaded INTEGER NOT NULL DEFAULT 0,
      isDefault INTEGER NOT NULL DEFAULT 0,
      version TEXT,
      lastUpdated INTEGER,
      downloadSize INTEGER NOT NULL,
      translations TEXT
    )
  ''';

  static const String createSettingsTable = '''
    CREATE TABLE ${DatabaseConfig.tableSettings} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      currentLanguageId TEXT NOT NULL,
      systemLanguage TEXT,
      lastUpdated INTEGER NOT NULL
    )
  ''';

  static const String createUserProfileTable = '''
    CREATE TABLE ${DatabaseConfig.tableUserProfiles} (
      id TEXT PRIMARY KEY,
      deviceId TEXT NOT NULL UNIQUE,
      createdAt TEXT NOT NULL,
      lastLoginAt TEXT NOT NULL,
      isPremium INTEGER NOT NULL DEFAULT 0,
      settings TEXT NOT NULL DEFAULT '{}'
    )
  ''';

  static const String createPuzzleRecordsTable = '''
    CREATE TABLE ${DatabaseConfig.tablePuzzleRecords} (
      recordId TEXT PRIMARY KEY,
      puzzleId TEXT NOT NULL,
      difficulty TEXT NOT NULL,
      completedAt TEXT NOT NULL,
      elapsedSeconds INTEGER NOT NULL,
      hintCount INTEGER NOT NULL DEFAULT 0
    )
  ''';
}
