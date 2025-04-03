import 'dart:async';

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  PuzzleNotifier() : super(const PuzzleState());

  Timer? _timer;

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  // 난이도 변경
  void changeDifficulty(Difficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  // 타이머 시작
  void startTimer() {
    if (state.isTimerRunning) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        elapsedTime: state.elapsedTime + const Duration(seconds: 1),
        isTimerRunning: true,
      );
    });
  }

  // 타이머 정지
  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  // 타이머 초기화 및 재시작
  void resetTimer() {
    stopTimer();
    state = state.copyWith(elapsedTime: Duration.zero);
    startTimer();
  }

  // 새 게임 초기화 (보드 데이터 주입)
  void initializeGameWithBoard({
    required List<List<CellContent>> gameBoard,
    required int boardSize,
  }) {
    state = state.copyWith(
      board: gameBoard,
      selectedRow: null,
      selectedCol: null,
      isCompleted: false,
      boardSize: boardSize,
      elapsedTime: Duration.zero,
    );
  }

  // 셀 선택
  void selectCell(int row, int col) {
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  // 보드 업데이트
  void updateBoard(List<List<CellContent>> newBoard, bool isCompleted) {
    state = state.copyWith(
      board: newBoard,
      isCompleted: isCompleted,
    );
  }

  // 게임 재시작
  void restartGame(List<List<CellContent>> newBoard) {
    state = state.copyWith(
      board: newBoard,
      selectedRow: null,
      selectedCol: null,
      isCompleted: false,
    );

    resetTimer();
  }
}
