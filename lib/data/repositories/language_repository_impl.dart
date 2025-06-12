import 'dart:async';
import 'dart:io';

import 'package:chessudoku/data/mock/language_mock_data.dart';
import 'package:chessudoku/data/models/language_pack.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/domain/repositories/language_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  final DatabaseService _databaseService;

  LanguageRepositoryImpl(this._databaseService);

  @override
  Future<List<LanguagePack>> getAvailableLanguagePacks() async {
    try {
      // Mock 서버 응답 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));

      final response = LanguageMockData.getMockServerResponse();
      if (response['status'] == 'success') {
        final languageData = response['data']['languages'] as List;
        return languageData.map((lang) => LanguagePack.fromMap(lang)).toList();
      }

      throw Exception('언어팩 데이터를 가져올 수 없습니다.');
    } catch (e) {
      debugPrint('[LanguageRepository] 언어팩 가져오기 실패: $e');
      rethrow;
    }
  }

  @override
  Future<List<LanguagePack>> getDownloadedLanguagePacks() async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tableLanguagePacks,
        where: 'isDownloaded = ?',
        whereArgs: [1],
      );

      return maps.map((map) => LanguagePack.fromMap(map)).toList();
    } catch (e) {
      debugPrint('[LanguageRepository] 다운로드된 언어팩 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<LanguagePack> downloadLanguagePack(String languageId) async {
    try {
      // 서버에서 언어팩 다운로드 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      final availablePacks = await getAvailableLanguagePacks();
      final targetPack = availablePacks.firstWhere(
        (pack) => pack.id == languageId,
        orElse: () => throw Exception('언어팩을 찾을 수 없습니다: $languageId'),
      );

      // 다운로드 완료 상태로 업데이트
      final downloadedPack = targetPack.copyWith(
        isDownloaded: true,
        lastUpdated: DateTime.now(),
      );

      // 데이터베이스에 저장 또는 업데이트
      await _databaseService.insert(
        DatabaseService.tableLanguagePacks,
        downloadedPack.toMap(),
      );

      debugPrint(
          '[LanguageRepository] 언어팩 다운로드 완료: ${downloadedPack.nativeName}');
      return downloadedPack;
    } catch (e) {
      debugPrint('[LanguageRepository] 언어팩 다운로드 실패: $e');
      rethrow;
    }
  }

  @override
  Future<LanguagePack> updateLanguagePack(String languageId) async {
    try {
      // 서버에서 최신 버전 확인 및 다운로드
      await Future.delayed(const Duration(seconds: 1));

      final availablePacks = await getAvailableLanguagePacks();
      final updatedPack = availablePacks.firstWhere(
        (pack) => pack.id == languageId,
        orElse: () => throw Exception('언어팩을 찾을 수 없습니다: $languageId'),
      );

      final finalPack = updatedPack.copyWith(
        isDownloaded: true,
        lastUpdated: DateTime.now(),
      );

      await _databaseService.update(
        DatabaseService.tableLanguagePacks,
        finalPack.toMap(),
        where: 'id = ?',
        whereArgs: [languageId],
      );

      debugPrint('[LanguageRepository] 언어팩 업데이트 완료: ${finalPack.nativeName}');
      return finalPack;
    } catch (e) {
      debugPrint('[LanguageRepository] 언어팩 업데이트 실패: $e');
      rethrow;
    }
  }

  @override
  Future<LanguagePack?> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLanguageId = prefs.getString('current_language_id');

      if (currentLanguageId == null) {
        return null;
      }

      final maps = await _databaseService.query(
        DatabaseService.tableLanguagePacks,
        where: 'id = ? AND isDownloaded = ?',
        whereArgs: [currentLanguageId, 1],
      );

      if (maps.isNotEmpty) {
        return LanguagePack.fromMap(maps.first);
      }

      return null;
    } catch (e) {
      debugPrint('[LanguageRepository] 현재 언어 조회 실패: $e');
      return null;
    }
  }

  @override
  Future<void> setCurrentLanguage(String languageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_language_id', languageId);

      debugPrint('[LanguageRepository] 현재 언어 설정 완료: $languageId');
    } catch (e) {
      debugPrint('[LanguageRepository] 현재 언어 설정 실패: $e');
      rethrow;
    }
  }

  @override
  Future<String> getSystemLanguage() async {
    try {
      final systemLocale = Platform.localeName;
      final parts = systemLocale.split('_');
      return parts.isNotEmpty ? parts[0] : 'ko';
    } catch (e) {
      debugPrint('[LanguageRepository] 시스템 언어 조회 실패: $e');
      return 'ko'; // 기본값으로 한국어 반환
    }
  }

  @override
  Future<void> clearLanguageCache() async {
    try {
      await _databaseService.delete(DatabaseService.tableLanguagePacks);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_language_id');

      debugPrint('[LanguageRepository] 언어 캐시 삭제 완료');
    } catch (e) {
      debugPrint('[LanguageRepository] 언어 캐시 삭제 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncLanguagePacks() async {
    try {
      debugPrint('[LanguageRepository] 언어팩 동기화 시작');

      // 서버에서 최신 언어팩 목록 가져오기
      final availablePacks = await getAvailableLanguagePacks();

      // 현재 언어 설정 확인
      final systemLanguage = await getSystemLanguage();
      final currentLanguage = await getCurrentLanguage();

      // 기본 언어팩(시스템 언어) 자동 다운로드
      if (currentLanguage == null) {
        // 시스템 언어에 해당하는 언어팩 찾기
        final systemPack = availablePacks
            .where(
                (pack) => pack.languageCode == systemLanguage || pack.isDefault)
            .firstOrNull;

        if (systemPack != null) {
          await downloadLanguagePack(systemPack.id);
          await setCurrentLanguage(systemPack.id);
          debugPrint(
              '[LanguageRepository] 기본 언어팩 설정 완료: ${systemPack.nativeName}');
        }
      }

      debugPrint('[LanguageRepository] 언어팩 동기화 완료');
    } catch (e) {
      debugPrint('[LanguageRepository] 언어팩 동기화 실패: $e');
      rethrow;
    }
  }
}
