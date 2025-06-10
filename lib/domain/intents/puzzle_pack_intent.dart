import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 퍼즐팩 관련 Intent들의 기본 클래스
sealed class PuzzlePackIntent extends BaseIntent {}

/// 모든 퍼즐팩 로드
class LoadAllPuzzlePacksIntent extends PuzzlePackIntent {}

/// 난이도별 퍼즐팩 로드
class LoadPuzzlePacksByDifficultyIntent extends PuzzlePackIntent {
  final Difficulty difficulty;

  LoadPuzzlePacksByDifficultyIntent({required this.difficulty});
}

/// 타입별 퍼즐팩 로드
class LoadPuzzlePacksByTypeIntent extends PuzzlePackIntent {
  final String type;

  LoadPuzzlePacksByTypeIntent({required this.type});
}

/// 추천 퍼즐팩 로드
class LoadRecommendedPuzzlePacksIntent extends PuzzlePackIntent {}

/// 추천 퍼즐팩 필터 초기화
class InitializeRecommendedPackFilterIntent extends PuzzlePackIntent {}

/// 추천 퍼즐팩 필터 타입 선택/해제
class ToggleRecommendedPackTypeFilterIntent extends PuzzlePackIntent {
  final String type;

  ToggleRecommendedPackTypeFilterIntent({required this.type});
}

/// 추천 퍼즐팩 필터 모두 선택/해제
class ToggleAllRecommendedPackFilterIntent extends PuzzlePackIntent {}

/// 프리미엄 퍼즐팩 로드
class LoadPremiumPuzzlePacksIntent extends PuzzlePackIntent {}

/// 퍼즐팩 진행률 업데이트
class UpdatePuzzlePackProgressIntent extends PuzzlePackIntent {
  final String packId;
  final int completedPuzzles;

  UpdatePuzzlePackProgressIntent({
    required this.packId,
    required this.completedPuzzles,
  });
}

/// 퍼즐팩 목록 새로고침
class RefreshPuzzlePacksIntent extends PuzzlePackIntent {}
