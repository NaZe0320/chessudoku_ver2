import 'package:chessudoku/data/models/language_pack.dart';

abstract interface class LanguageRepository {
  /// 사용 가능한 언어팩 목록 가져오기 (서버에서)
  Future<List<LanguagePack>> getAvailableLanguagePacks();

  /// 다운로드된 언어팩 목록 가져오기 (로컬 DB에서)
  Future<List<LanguagePack>> getDownloadedLanguagePacks();

  /// 언어팩 다운로드
  Future<LanguagePack> downloadLanguagePack(String languageId);

  /// 언어팩 업데이트
  Future<LanguagePack> updateLanguagePack(String languageId);

  /// 현재 언어 설정 가져오기
  Future<LanguagePack?> getCurrentLanguage();

  /// 현재 언어 설정 저장
  Future<void> setCurrentLanguage(String languageId);

  /// 시스템 기본 언어 가져오기
  Future<String> getSystemLanguage();

  /// 언어팩 캐시에서 삭제
  Future<void> clearLanguageCache();

  /// 모든 언어팩 데이터 동기화
  Future<void> syncLanguagePacks();
}
