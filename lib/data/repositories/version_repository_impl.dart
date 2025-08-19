import 'package:chessudoku/domain/repositories/language_repository.dart';
import 'package:chessudoku/domain/repositories/version_repository.dart';
import 'package:flutter/foundation.dart';

class VersionRepositoryImpl implements VersionRepository {
  final LanguageRepository _languageRepository;

  VersionRepositoryImpl({
    required LanguageRepository languageRepository,
  }) : _languageRepository = languageRepository;

  @override
  Future<void> checkVersionAndSync(
      {void Function(double progress, String message)? onProgress}) async {
    onProgress?.call(0.0, '데이터 버전 확인 중...');
    debugPrint('[VersionRepository] 데이터 버전 체크 및 동기화 시작...');

    try {
      // 로컬 데이터베이스에서 버전 정보 확인
      onProgress?.call(0.3, '로컬 데이터 확인 중...');

      // 언어 팩 동기화만 수행 (로컬 데이터베이스 기반)
      onProgress?.call(0.6, '언어 팩 동기화 중...');
      await _languageRepository.syncLanguagePacks();

      onProgress?.call(0.9, '동기화 완료!');
      debugPrint('[VersionRepository] 데이터 버전 체크 및 동기화 완료.');
      await Future.delayed(const Duration(milliseconds: 300));
      onProgress?.call(1.0, '앱을 시작합니다.');
    } catch (e) {
      debugPrint('[VersionRepository] 버전 체크 중 오류 발생: $e');
      onProgress?.call(1.0, '오류가 발생했습니다.');
      // 오류 처리 로직 (예: 사용자에게 알림 등)
    }
  }
}
