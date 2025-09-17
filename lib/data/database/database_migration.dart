import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// 데이터베이스 마이그레이션 관리 클래스
/// 버전 1로 초기화했으므로 현재는 마이그레이션 로직이 최소화됨
class DatabaseMigration {
  /// 데이터베이스 마이그레이션 실행
  /// 향후 버전 업그레이드 시에만 사용
  static Future<void> migrate(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      debugPrint('데이터베이스 마이그레이션: $oldVersion -> $newVersion');
      // 향후 마이그레이션 로직 추가 예정
      // 현재는 버전 1이므로 마이그레이션 불필요
    }
  }
}
