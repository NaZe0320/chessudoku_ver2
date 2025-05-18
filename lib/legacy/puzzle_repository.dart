import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/legacy/puzzle_state.dart';

/// 퍼즐 저장소의 추상 인터페이스
abstract class PuzzleRepository {
  /// 퍼즐 상태를 저장
  Future<bool> savePuzzleState(PuzzleState state);

  /// 퍼즐 상태를 불러오기
  Future<PuzzleState?> loadPuzzleState([Difficulty? difficulty]);

  /// 퍼즐 상태 삭제
  Future<bool> clearPuzzleState([Difficulty? difficulty]);

  /// 캐시된 퍼즐 상태 존재 여부 확인
  bool hasCachedPuzzleState([Difficulty? difficulty]);
}
