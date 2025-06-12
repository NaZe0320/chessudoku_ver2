import 'package:chessudoku/data/models/language_pack.dart';
import 'package:chessudoku/domain/repositories/language_repository.dart';
import 'package:chessudoku/domain/states/language_pack_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguagePackNotifier extends StateNotifier<LanguagePackState> {
  final LanguageRepository _languageRepository;

  LanguagePackNotifier(this._languageRepository)
      : super(const LanguagePackState());

  /// 언어팩 목록 로드 (사용 가능한 언어팩 + 다운로드된 언어팩)
  Future<void> loadLanguagePacks() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 병렬로 데이터 가져오기
      final futures = await Future.wait([
        _languageRepository.getAvailableLanguagePacks(),
        _languageRepository.getDownloadedLanguagePacks(),
        _languageRepository.getCurrentLanguage(),
      ]);

      final availablePacks = futures[0] as List<LanguagePack>;
      final downloadedPacks = futures[1] as List<LanguagePack>;
      final currentLanguage = futures[2] as LanguagePack?;

      // 다운로드 상태를 반영한 언어팩 목록 생성
      final allPacks = availablePacks.map((pack) {
        final isDownloaded =
            downloadedPacks.any((downloaded) => downloaded.id == pack.id);
        return pack.copyWith(isDownloaded: isDownloaded);
      }).toList();

      state = state.copyWith(
        languagePacks: allPacks,
        currentLanguagePack: currentLanguage,
        isLoading: false,
      );

      debugPrint('[LanguagePackNotifier] 언어팩 로드 완료: ${allPacks.length}개');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      debugPrint('[LanguagePackNotifier] 언어팩 로드 실패: $error');
    }
  }

  /// 언어팩 다운로드
  Future<void> downloadLanguagePack(String languageId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final downloadedPack =
          await _languageRepository.downloadLanguagePack(languageId);

      // 상태 업데이트
      final updatedPacks = state.languagePacks.map((pack) {
        if (pack.id == languageId) {
          return downloadedPack;
        }
        return pack;
      }).toList();

      state = state.copyWith(
        languagePacks: updatedPacks,
        isLoading: false,
      );

      debugPrint(
          '[LanguagePackNotifier] 언어팩 다운로드 완료: ${downloadedPack.nativeName}');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      debugPrint('[LanguagePackNotifier] 언어팩 다운로드 실패: $error');
    }
  }

  /// 언어팩 업데이트
  Future<void> updateLanguagePack(String languageId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final updatedPack =
          await _languageRepository.updateLanguagePack(languageId);

      // 상태 업데이트
      final updatedPacks = state.languagePacks.map((pack) {
        if (pack.id == languageId) {
          return updatedPack;
        }
        return pack;
      }).toList();

      state = state.copyWith(
        languagePacks: updatedPacks,
        isLoading: false,
      );

      debugPrint(
          '[LanguagePackNotifier] 언어팩 업데이트 완료: ${updatedPack.nativeName}');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      debugPrint('[LanguagePackNotifier] 언어팩 업데이트 실패: $error');
    }
  }

  /// 현재 언어 변경
  Future<void> changeLanguage(String languageId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _languageRepository.setCurrentLanguage(languageId);

      // 새로운 현재 언어 설정
      final newCurrentLanguage = state.languagePacks.firstWhere(
        (pack) => pack.id == languageId,
        orElse: () => throw Exception('언어팩을 찾을 수 없습니다: $languageId'),
      );

      state = state.copyWith(
        currentLanguagePack: newCurrentLanguage,
        isLoading: false,
      );

      debugPrint(
          '[LanguagePackNotifier] 언어 변경 완료: ${newCurrentLanguage.nativeName}');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      debugPrint('[LanguagePackNotifier] 언어 변경 실패: $error');
    }
  }

  /// 언어팩 동기화 (앱 시작 시 호출)
  Future<void> syncLanguagePacks() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _languageRepository.syncLanguagePacks();
      await loadLanguagePacks();

      debugPrint('[LanguagePackNotifier] 언어팩 동기화 완료');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      debugPrint('[LanguagePackNotifier] 언어팩 동기화 실패: $error');
    }
  }

  /// 번역 텍스트 가져오기
  String translate(String key, [String? defaultValue]) {
    return state.translate(key, defaultValue);
  }

  /// 현재 언어 코드
  String get currentLanguageCode => state.currentLanguageCode;

  /// 앱 시작 시 저장된 언어 설정 복원
  Future<void> restoreLanguageSettings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      debugPrint('[LanguagePackNotifier] 저장된 언어 설정 복원 시작');

      // 병렬로 데이터 가져오기
      final futures = await Future.wait([
        _languageRepository.getAvailableLanguagePacks(),
        _languageRepository.getDownloadedLanguagePacks(),
        _languageRepository.getCurrentLanguage(),
      ]);

      final availablePacks = futures[0] as List<LanguagePack>;
      final downloadedPacks = futures[1] as List<LanguagePack>;
      final currentLanguage = futures[2] as LanguagePack?;

      // 다운로드 상태를 반영한 언어팩 목록 생성
      final allPacks = availablePacks.map((pack) {
        final isDownloaded =
            downloadedPacks.any((downloaded) => downloaded.id == pack.id);
        return pack.copyWith(isDownloaded: isDownloaded);
      }).toList();

      state = state.copyWith(
        languagePacks: allPacks,
        currentLanguagePack: currentLanguage,
        isLoading: false,
      );

      if (currentLanguage != null) {
        debugPrint(
            '[LanguagePackNotifier] 언어 설정 복원 완료: ${currentLanguage.nativeName}');
      } else {
        debugPrint('[LanguagePackNotifier] 저장된 언어 설정이 없습니다.');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      debugPrint('[LanguagePackNotifier] 언어 설정 복원 실패: $error');
    }
  }
}
