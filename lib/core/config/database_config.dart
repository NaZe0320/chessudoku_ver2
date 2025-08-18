/// 데이터베이스 설정 관리 클래스
class DatabaseConfig {
  static const String dbName = 'chessudoku.db';
  static const int dbVersion = 1; // 버전 1로 초기화
  static const Duration timeout = Duration(seconds: 30);

  // 테이블 이름들
  static const String tableDataVersions = 'data_versions';
  static const String tableLanguagePacks = 'language_packs';
  static const String tableSettings = 'settings';
  static const String tableUserProfiles = 'user_profiles';
  static const String tablePuzzleRecords = 'puzzle_records';
}
