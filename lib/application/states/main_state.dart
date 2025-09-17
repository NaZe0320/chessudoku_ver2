import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/entities/game_board.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

part 'main_state.freezed.dart';

@freezed
class MainState with _$MainState {
  const factory MainState({
    @Default(false) bool isLoading,
    @Default(false) bool hasSavedGame,
    String? savedGameInfo, // 저장된 게임 정보 (예: "보통 난이도 • 8번 정답 • 65% 완료")

    // 게임 시작 관련 정보
    GameBoard? savedGameBoard, // 저장된 게임 보드
    Difficulty? selectedDifficulty, // 선택된 난이도
    @Default(false) bool shouldStartNewGame, // 새 게임 시작 여부
    @Default(false) bool shouldContinueGame, // 이어서 게임 시작 여부
  }) = _MainState;
}
