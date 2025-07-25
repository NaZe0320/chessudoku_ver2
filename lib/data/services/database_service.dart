import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 앱 전체에서 사용할 수 있는 데이터베이스 서비스
/// SQLite 데이터베이스 관리를 담당하는 싱글톤 클래스
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // 데이터베이스 이름
  static const String _dbName = 'chessudoku.db';
  // 데이터베이스 버전
  static const int _dbVersion = 3;

  // 테이블 이름
  static const String tableDataVersions = 'data_versions';
  static const String tableLanguagePacks = 'language_packs';
  static const String tableSettings = 'settings';
  static const String tableUserProfiles = 'user_profiles';
  static const String tablePuzzleRecords = 'puzzle_records';

  // 싱글톤 패턴 적용
  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    debugPrint('데이터베이스 초기화: $path (버전 $_dbVersion)');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) {
        debugPrint('데이터베이스 열림: ${db.path}');
      },
    );
  }

  /// 데이터베이스 생성
  Future<void> _createDB(Database db, int version) async {
    debugPrint('새 데이터베이스 생성 중... 버전: $version');
    await _createTables(db);
  }

  /// 데이터베이스 업그레이드
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('데이터베이스 업그레이드: $oldVersion -> $newVersion');

    if (oldVersion < 2) {
      await _createDataVersionsTable(db);
      await _createLanguageTables(db);
    }

    if (oldVersion < 3) {
      await _createUserProfileTable(db);
      await _createPuzzleRecordsTable(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await _createDataVersionsTable(db);
    await _createLanguageTables(db);
    await _createSettingsTable(db);
    await _createUserProfileTable(db);
    await _createPuzzleRecordsTable(db);
  }

  Future<void> _createDataVersionsTable(Database db) async {
    // 데이터 버전 관리 테이블 생성
    await db.execute('''
      CREATE TABLE $tableDataVersions (
        dataType TEXT PRIMARY KEY,
        version INTEGER NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    debugPrint('데이터 버전 테이블 생성 완료: $tableDataVersions');
  }

  Future<void> _createLanguageTables(Database db) async {
    // 언어팩 테이블 생성
    await db.execute('''
      CREATE TABLE $tableLanguagePacks (
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
    ''');
    debugPrint('언어팩 테이블 생성 완료: $tableLanguagePacks');
  }

  Future<void> _createSettingsTable(Database db) async {
    // 설정 테이블 생성
    await db.execute('''
      CREATE TABLE $tableSettings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currentLanguageId TEXT NOT NULL,
        systemLanguage TEXT,
        lastUpdated INTEGER NOT NULL
      )
    ''');
    debugPrint('설정 테이블 생성 완료: $tableSettings');
  }

  Future<void> _createUserProfileTable(Database db) async {
    // 사용자 프로필 테이블 생성
    await db.execute('''
      CREATE TABLE $tableUserProfiles (
        deviceId TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT NOT NULL,
        totalPlayTime INTEGER NOT NULL DEFAULT 0,
        completedPuzzles INTEGER NOT NULL DEFAULT 0,
        currentStreak INTEGER NOT NULL DEFAULT 0,
        bestStreak INTEGER NOT NULL DEFAULT 0
      )
    ''');
    debugPrint('사용자 프로필 테이블 생성 완료: $tableUserProfiles');
  }

  Future<void> _createPuzzleRecordsTable(Database db) async {
    // 퍼즐 기록 테이블 생성
    await db.execute('''
      CREATE TABLE $tablePuzzleRecords (
        recordId TEXT PRIMARY KEY,
        puzzleId TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        completedAt TEXT NOT NULL,
        elapsedSeconds INTEGER NOT NULL,
        hintCount INTEGER NOT NULL DEFAULT 0
      )
    ''');
    debugPrint('퍼즐 기록 테이블 생성 완료: $tablePuzzleRecords');
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  /// 레코드 삽입
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 레코드 조회
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// 레코드 업데이트
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// 레코드 삭제
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// 데이터베이스 초기화 (모든 데이터 삭제)
  Future<void> resetDatabase() async {
    final db = await database;
    // 퍼즐 관련 테이블 제거됨
  }
}
