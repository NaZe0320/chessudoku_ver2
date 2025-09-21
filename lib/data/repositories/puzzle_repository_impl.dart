import 'dart:developer' as developer;
import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:chessudoku/domain/entities/puzzle.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/data/services/api_service.dart';
import 'package:chessudoku/core/config/api_endpoints.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';

/// 서버 API를 사용한 퍼즐 repository 구현체
class PuzzleRepositoryImpl implements PuzzleRepository {
  final ApiService _apiService;

  PuzzleRepositoryImpl(this._apiService);

  @override
  Future<Puzzle?> getRandomPuzzle({
    String? puzzleType,
    Difficulty? difficulty,
  }) async {
    try {
      developer.log('랜덤 퍼즐 조회 시작 (타입: $puzzleType, 난이도: $difficulty)',
          name: 'PuzzleRepository');

      // 네트워크 연결 확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('네트워크 연결 없음', name: 'PuzzleRepository');
        return null;
      }

      // 쿼리 파라미터 구성
      final queryParameters = <String, dynamic>{};
      if (puzzleType != null) {
        queryParameters['puzzle_type'] = puzzleType;
      }
      if (difficulty != null) {
        queryParameters['difficulty'] = difficulty.name;
      }

      // 서버에서 랜덤 퍼즐 조회
      final response = await _apiService.get(
        ApiEndpoints.randomPuzzle,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final puzzleData = responseData['data'] as Map<String, dynamic>;

        final puzzle = Puzzle.fromServerResponse(puzzleData);

        developer.log('서버에서 랜덤 퍼즐 조회 완료', name: 'PuzzleRepository');
        return puzzle;
      } else {
        developer.log('서버 랜덤 퍼즐 조회 실패: ${response.statusCode}',
            name: 'PuzzleRepository');
        return null;
      }
    } catch (e) {
      developer.log('랜덤 퍼즐 조회 실패: $e', name: 'PuzzleRepository');
      return null;
    }
  }

  @override
  Future<Puzzle?> getDailyPuzzle({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(targetDate);

      developer.log('데일리 퍼즐 조회 시작 (날짜: $dateString)', name: 'PuzzleRepository');

      // 네트워크 연결 확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('네트워크 연결 없음', name: 'PuzzleRepository');
        return null;
      }

      // 서버에서 데일리 퍼즐 조회
      final response = await _apiService.get(
        ApiEndpoints.dailyPuzzle,
        queryParameters: {'date': dateString},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final puzzleData = responseData['data'] as Map<String, dynamic>;

        final puzzle = Puzzle.fromServerResponse(puzzleData);

        developer.log('서버에서 데일리 퍼즐 조회 완료', name: 'PuzzleRepository');
        return puzzle;
      } else if (response.statusCode == 404) {
        developer.log('해당 날짜의 데일리 퍼즐이 없습니다: $dateString',
            name: 'PuzzleRepository');
        return null;
      } else {
        developer.log('서버 데일리 퍼즐 조회 실패: ${response.statusCode}',
            name: 'PuzzleRepository');
        return null;
      }
    } catch (e) {
      developer.log('데일리 퍼즐 조회 실패: $e', name: 'PuzzleRepository');
      return null;
    }
  }
}
