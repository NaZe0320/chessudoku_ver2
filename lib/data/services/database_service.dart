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
  static const int _dbVersion = 1;

  // 테이블 이름
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

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
    );
  }

  /// 데이터베이스 생성
  Future<void> _createDB(Database db, int version) async {
    // 퍼즐 기록 테이블 생성
    await db.execute('''
      CREATE TABLE $tablePuzzleRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        difficulty TEXT NOT NULL,
        boardData TEXT NOT NULL,
        completionTime INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
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
    await db.delete(tablePuzzleRecords);
  }
}
