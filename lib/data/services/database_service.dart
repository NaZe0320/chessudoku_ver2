import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/config/database_config.dart';
import '../database/table_schemas.dart';
import '../database/database_migration.dart';

/// 앱 전체에서 사용할 수 있는 데이터베이스 서비스
/// SQLite 데이터베이스 관리를 담당하는 클래스
class DatabaseService {
  Database? _database;

  // 일반 생성자 사용
  DatabaseService();

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConfig.dbName);

    debugPrint('데이터베이스 초기화: $path (버전 ${DatabaseConfig.dbVersion})');

    return await openDatabase(
      path,
      version: DatabaseConfig.dbVersion,
      onCreate: _createDB,
      onUpgrade: DatabaseMigration.migrate,
      onOpen: (db) {
        debugPrint('데이터베이스 열림: ${db.path}');
      },
    );
  }

  /// 데이터베이스 생성
  Future<void> _createDB(Database db, int version) async {
    debugPrint('새 데이터베이스 생성 중... 버전: $version');
    await _createAllTables(db);
  }

  /// 모든 테이블 생성
  Future<void> _createAllTables(Database db) async {
    await db.execute(TableSchemas.createDataVersionsTable);
    await db.execute(TableSchemas.createLanguagePacksTable);
    await db.execute(TableSchemas.createSettingsTable);
    await db.execute(TableSchemas.createUserProfileTable);
    await db.execute(TableSchemas.createPuzzleRecordsTable);
    debugPrint('모든 테이블 생성 완료');
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 레코드 삽입
  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('데이터 삽입 실패: $e');
    }
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
    try {
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
    } catch (e) {
      throw DatabaseException('데이터 조회 실패: $e');
    }
  }

  /// 레코드 업데이트
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      throw DatabaseException('데이터 업데이트 실패: $e');
    }
  }

  /// 레코드 삭제
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      throw DatabaseException('데이터 삭제 실패: $e');
    }
  }

  /// 데이터베이스 초기화 (모든 데이터 삭제)
  Future<void> resetDatabase() async {
    try {
      final db = await database;
      await db.close();
      _database = null;

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, DatabaseConfig.dbName);

      // 데이터베이스 파일 삭제
      await deleteDatabase(path);
      debugPrint('데이터베이스 초기화 완료');
    } catch (e) {
      throw DatabaseException('데이터베이스 초기화 실패: $e');
    }
  }
}

/// 데이터베이스 예외 클래스
class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
