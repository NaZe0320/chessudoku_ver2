import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/checkpoint.dart';
import 'package:chessudoku/data/models/cell_content.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    @Default(false) bool isLoading,
    CellContent? selectedCellContent, // 현재 선택된 셀의 내용
    @Default(0) int elapsedSeconds,
    @Default(false) bool isPaused, // 일시 정지 상태 (isTimerRunning 대신 사용)
    GameBoard? currentBoard, // 현재 게임 보드
    @Default([]) List<GameBoard> history, // 되돌리기용 히스토리
    @Default([]) List<GameBoard> redoHistory, // 다시 실행용 히스토리
    @Default({}) Map<String, Checkpoint> checkpoints, // 분기점 저장 (체크포인트)
    @Default(false) bool canUndo, // 되돌리기 가능 여부
    @Default(false) bool canRedo, // 다시 실행 가능 여부
    @Default(false) bool isGameCompleted, // 게임 완료 여부
    @Default(false) bool showCompletionDialog, // 완료 다이얼로그 표시 여부
  }) = _GameState;
}
