import 'package:flutter/material.dart';
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
  static const String tablePuzzlePacks = 'puzzle_packs';

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

    print('데이터베이스 초기화: $path (버전 $_dbVersion)');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onOpen: (db) {
        debugPrint(
            '데이터베이스 열림: ${db.path}, 테이블: $tablePuzzleRecords, $tablePuzzlePacks');
      },
    );
  }

  /// 데이터베이스 생성
  Future<void> _createDB(Database db, int version) async {
    debugPrint('새 데이터베이스 생성 중... 버전: $version');

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
    print('퍼즐 기록 테이블 생성 완료: $tablePuzzleRecords');

    // 퍼즐팩 테이블 생성
    await db.execute('''
      CREATE TABLE $tablePuzzlePacks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        total_puzzles INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        types TEXT NOT NULL,
        is_premium INTEGER NOT NULL DEFAULT 0,
        icon_asset TEXT NOT NULL,
        completed_puzzles INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    print('퍼즐팩 테이블 생성 완료: $tablePuzzlePacks');

    // 인덱스 생성
    await db.execute(
        'CREATE INDEX idx_difficulty ON $tablePuzzlePacks(difficulty)');
    await db
        .execute('CREATE INDEX idx_premium ON $tablePuzzlePacks(is_premium)');

    // Mock 데이터 삽입
    await _insertMockPuzzlePacks(db);
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

  /// Mock 퍼즐팩 데이터 삽입
  Future<void> _insertMockPuzzlePacks(Database db) async {
    print('Mock 퍼즐팩 데이터 삽입 중...');

    final mockData = [
      {
        'id': 'beginner_pack_1',
        'name': '초보자 입문팩',
        'total_puzzles': 20,
        'difficulty': 'easy',
        'types': '["기본", "입문"]',
        'is_premium': 0,
        'icon_asset': 'assets/icons/beginner_pack.png',
        'completed_puzzles': 5,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'classic_pack_1',
        'name': '클래식 체스도쿠',
        'total_puzzles': 50,
        'difficulty': 'medium',
        'types': '["클래식", "중급"]',
        'is_premium': 0,
        'icon_asset': 'assets/icons/classic_pack.png',
        'completed_puzzles': 15,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'expert_pack_1',
        'name': '전문가 도전팩',
        'total_puzzles': 30,
        'difficulty': 'hard',
        'types': '["고급", "도전"]',
        'is_premium': 1,
        'icon_asset': 'assets/icons/expert_pack.png',
        'completed_puzzles': 3,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'daily_pack',
        'name': '일일 퍼즐팩',
        'total_puzzles': 7,
        'difficulty': 'medium',
        'types': '["일일", "특별"]',
        'is_premium': 0,
        'icon_asset': 'assets/icons/daily_pack.png',
        'completed_puzzles': 2,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'premium_ultimate',
        'name': '궁극의 마스터팩',
        'total_puzzles': 100,
        'difficulty': 'expert',
        'types': '["마스터", "궁극"]',
        'is_premium': 1,
        'icon_asset': 'assets/icons/ultimate_pack.png',
        'completed_puzzles': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'speed_pack',
        'name': '스피드 러닝팩',
        'total_puzzles': 25,
        'difficulty': 'medium',
        'types': '["스피드", "타임어택"]',
        'is_premium': 0,
        'icon_asset': 'assets/icons/speed_pack.png',
        'completed_puzzles': 8,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'brain_training',
        'name': '두뇌 트레이닝팩',
        'total_puzzles': 40,
        'difficulty': 'easy',
        'types': '["트레이닝", "두뇌"]',
        'is_premium': 0,
        'icon_asset': 'assets/icons/brain_pack.png',
        'completed_puzzles': 12,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'master_challenge',
        'name': '마스터 챌린지팩',
        'total_puzzles': 60,
        'difficulty': 'expert',
        'types': '["챌린지", "마스터"]',
        'is_premium': 1,
        'icon_asset': 'assets/icons/master_pack.png',
        'completed_puzzles': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    final batch = db.batch();
    for (final pack in mockData) {
      batch.insert(tablePuzzlePacks, pack);
    }
    await batch.commit();

    print('Mock 퍼즐팩 데이터 ${mockData.length}개 삽입 완료');
  }

  /// 데이터베이스 초기화 (모든 데이터 삭제)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete(tablePuzzleRecords);
    await db.delete(tablePuzzlePacks);
  }

  /// 퍼즐팩 Mock 데이터 재삽입
  Future<void> resetPuzzlePacksWithMockData() async {
    final db = await database;
    await db.delete(tablePuzzlePacks);
    await _insertMockPuzzlePacks(db);
  }
}
