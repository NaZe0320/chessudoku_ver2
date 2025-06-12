import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/test_service.dart';
import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:chessudoku/domain/repositories/version_repository.dart';
import 'package:flutter/foundation.dart';

class VersionRepositoryImpl implements VersionRepository {
  final DatabaseService _databaseService;
  final TestService _testService;
  final PuzzleRepository _puzzleRepository;

  VersionRepositoryImpl({
    required DatabaseService databaseService,
    required TestService testService,
    required PuzzleRepository puzzleRepository,
  })  : _databaseService = databaseService,
        _testService = testService,
        _puzzleRepository = puzzleRepository;

  @override
  Future<void> checkVersionAndSync(
      {void Function(double progress, String message)? onProgress}) async {
    onProgress?.call(0.0, '데이터 버전 확인 중...');
    debugPrint('[VersionRepository] 데이터 버전 체크 및 동기화 시작...');

    try {
      // 1. 서버로부터 최신 데이터 버전 정보 가져오기 (현재는 Mock 데이터 사용)
      onProgress?.call(0.1, '서버 버전 정보 확인 중...');
      final serverVersions = await _testService.getServerDataVersions();
      debugPrint('[VersionRepository] 서버 버전 정보: $serverVersions');

      final dataTypes = serverVersions.keys.toList();
      final totalSteps = dataTypes.length * 2; // 각 타입별 (체크 + 동기화)
      int currentStep = 0;

      // 2. 각 데이터 타입에 대해 버전 비교 및 동기화
      for (int i = 0; i < dataTypes.length; i++) {
        final dataType = dataTypes[i];
        final serverVersion = serverVersions[dataType]!;

        // 로컬 데이터 버전 조회
        onProgress?.call(
          0.1 + (currentStep / totalSteps) * 0.8,
          '$dataType 데이터 버전 확인 중...',
        );
        final localVersion = await _getDataVersion(dataType);
        debugPrint(
            '[VersionRepository] 로컬 $dataType 버전: $localVersion, 서버 버전: $serverVersion');
        currentStep++;

        if (serverVersion > localVersion) {
          debugPrint(
              '[VersionRepository] 새로운 $dataType 데이터($serverVersion) 발견. 동기화를 시작합니다.');

          // 3. 데이터 동기화 로직 호출
          onProgress?.call(
            0.1 + (currentStep / totalSteps) * 0.8,
            '$dataType 데이터 다운로드 중...',
          );
          await _syncData(dataType, serverVersion);

          // 4. 동기화 완료 후 로컬 데이터 버전 업데이트
          await _updateDataVersion(dataType, serverVersion);
          debugPrint(
              '[VersionRepository] 로컬 $dataType 버전이 $serverVersion 으로 업데이트되었습니다.');
        } else {
          debugPrint('[VersionRepository] $dataType 데이터는 이미 최신 버전입니다.');
        }
        currentStep++;
      }

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

  /// 로컬 DB에서 데이터 타입별 버전 조회
  Future<int> _getDataVersion(String dataType) async {
    final result = await _databaseService.query(
      DatabaseService.tableDataVersions,
      columns: ['version'],
      where: 'dataType = ?',
      whereArgs: [dataType],
    );

    if (result.isNotEmpty) {
      return result.first['version'] as int;
    } else {
      // 해당 데이터 타입의 버전 정보가 없으면 0을 반환
      return 0;
    }
  }

  /// 로컬 DB의 데이터 타입별 버전 업데이트 또는 삽입
  Future<void> _updateDataVersion(String dataType, int version) async {
    await _databaseService.insert(
      DatabaseService.tableDataVersions,
      {
        'dataType': dataType,
        'version': version,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 데이터 타입별 동기화 로직
  Future<void> _syncData(String dataType, int version) async {
    // TODO: 각 데이터 타입에 맞는 Repository를 통해 실제 데이터 동기화 구현
    // 예를 들어, PuzzleRepository, NoticeRepository 등을 호출
    switch (dataType) {
      case 'puzzles':
        await _puzzleRepository.syncPuzzles(version);
        debugPrint('[$dataType] 동기화 중... (구현)');
        await Future.delayed(
            const Duration(milliseconds: 1000)); // Simulate network latency
        break;
      case 'notices':
        // await _noticeRepository.syncNotices();
        debugPrint('[$dataType] 동기화 중... (구현 필요)');
        await Future.delayed(const Duration(milliseconds: 500));
        break;
      case 'achievements':
        // await _achievementRepository.syncAchievements();
        debugPrint('[$dataType] 동기화 중... (구현 필요)');
        await Future.delayed(const Duration(milliseconds: 800));
        break;
      default:
        debugPrint('[$dataType] 알 수 없는 데이터 타입입니다. 동기화를 건너뜁니다.');
    }
  }
}
