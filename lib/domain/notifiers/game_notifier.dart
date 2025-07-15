import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/domain/states/game_state.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:flutter/material.dart';

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(GameState initialState) : super(initialState);

  /// Intent를 처리하는 메인 메서드
  void handleIntent(GameIntent intent) {
    if (intent is SelectCellIntent) {
      _selectCell(intent.row, intent.col);
    } else if (intent is InputNumberIntent) {
      _inputNumber(intent.number);
    } else if (intent is ClearCellIntent) {
      _clearCell();
    } else if (intent is ToggleNoteIntent) {
      _toggleNote(intent.number);
    } else if (intent is StartGameIntent) {
      _startGame(intent);
    } else if (intent is PauseGameIntent) {
      _pauseGame();
    } else if (intent is ResumeGameIntent) {
      _resumeGame();
    } else if (intent is CheckGameCompletionIntent) {
      _checkGameCompletion();
    }
  }

  /// 새 게임 시작
  void _startGame(StartGameIntent intent) {
    state = GameState(
      gameId: intent.gameId,
      difficulty: intent.difficulty,
      board: _deepCopyBoard(intent.initialBoard),
      selectedRow: null,
      selectedCol: null,
      isCompleted: false,
      elapsedTime: Duration.zero,
      isPaused: false,
      boardSize: intent.initialBoard.length,
    );
    debugPrint('Game started: ${intent.gameId}');
  }

  /// 셀 선택 처리
  void _selectCell(int row, int col) {
    // 유효한 셀 범위인지 확인
    if (row < 0 ||
        row >= state.boardSize ||
        col < 0 ||
        col >= state.boardSize) {
      debugPrint('Invalid cell selection: ($row, $col)');
      return;
    }

    // 게임이 완료되었거나 일시정지된 경우 선택 불가
    if (state.isCompleted || state.isPaused) {
      debugPrint(
          'Cannot select cell: game is ${state.isCompleted ? 'completed' : 'paused'}');
      return;
    }

    // 현재 선택된 셀과 같은 셀을 클릭한 경우 선택 해제
    if (state.selectedRow == row && state.selectedCol == col) {
      state = state.copyWith(
        selectedRow: null,
        selectedCol: null,
      );
      debugPrint('Cell deselected: ($row, $col)');
    } else {
      // 새로운 셀 선택
      state = state.copyWith(
        selectedRow: row,
        selectedCol: col,
      );
      debugPrint('Cell selected: ($row, $col)');
    }
  }

  /// 숫자 입력 처리
  void _inputNumber(int number) {
    if (state.selectedRow == null || state.selectedCol == null) {
      debugPrint('No cell selected for number input');
      return;
    }

    if (state.isCompleted || state.isPaused) {
      debugPrint(
          'Cannot input number: game is ${state.isCompleted ? 'completed' : 'paused'}');
      return;
    }

    final selectedCell = state.board[state.selectedRow!][state.selectedCol!];

    // 초기값인 경우 수정 불가
    if (selectedCell.isInitial) {
      debugPrint('Cannot modify initial cell value');
      return;
    }

    // 보드 복사 및 셀 업데이트
    final newBoard = _deepCopyBoard(state.board);
    newBoard[state.selectedRow!][state.selectedCol!] = selectedCell.copyWith(
      number: number,
      notes: {}, // 숫자 입력 시 노트 제거
    );

    state = state.copyWith(board: newBoard);
    debugPrint(
        'Number $number input to cell (${state.selectedRow}, ${state.selectedCol})');

    // 게임 완료 체크
    _checkGameCompletion();
  }

  /// 선택된 셀 지우기
  void _clearCell() {
    if (state.selectedRow == null || state.selectedCol == null) {
      debugPrint('No cell selected for clearing');
      return;
    }

    if (state.isCompleted || state.isPaused) {
      debugPrint(
          'Cannot clear cell: game is ${state.isCompleted ? 'completed' : 'paused'}');
      return;
    }

    final selectedCell = state.board[state.selectedRow!][state.selectedCol!];

    // 초기값인 경우 수정 불가
    if (selectedCell.isInitial) {
      debugPrint('Cannot clear initial cell value');
      return;
    }

    // 보드 복사 및 셀 클리어
    final newBoard = _deepCopyBoard(state.board);
    newBoard[state.selectedRow!][state.selectedCol!] = selectedCell.copyWith(
      number: null,
      notes: {},
    );

    state = state.copyWith(board: newBoard);
    debugPrint('Cell cleared: (${state.selectedRow}, ${state.selectedCol})');
  }

  /// 노트 토글
  void _toggleNote(int number) {
    if (state.selectedRow == null || state.selectedCol == null) {
      debugPrint('No cell selected for note toggle');
      return;
    }

    if (state.isCompleted || state.isPaused) {
      debugPrint(
          'Cannot toggle note: game is ${state.isCompleted ? 'completed' : 'paused'}');
      return;
    }

    final selectedCell = state.board[state.selectedRow!][state.selectedCol!];

    // 초기값이거나 이미 숫자가 입력된 경우 노트 불가
    if (selectedCell.isInitial || selectedCell.hasNumber) {
      debugPrint('Cannot add note to cell with number or initial value');
      return;
    }

    // 보드 복사 및 노트 토글
    final newBoard = _deepCopyBoard(state.board);
    newBoard[state.selectedRow!][state.selectedCol!] =
        selectedCell.toggleNote(number);

    state = state.copyWith(board: newBoard);
    debugPrint(
        'Note $number toggled for cell (${state.selectedRow}, ${state.selectedCol})');
  }

  /// 게임 일시정지
  void _pauseGame() {
    if (state.isCompleted) {
      debugPrint('Cannot pause completed game');
      return;
    }

    state = state.copyWith(isPaused: true);
    debugPrint('Game paused');
  }

  /// 게임 재개
  void _resumeGame() {
    if (state.isCompleted) {
      debugPrint('Cannot resume completed game');
      return;
    }

    state = state.copyWith(isPaused: false);
    debugPrint('Game resumed');
  }

  /// 게임 완료 체크
  void _checkGameCompletion() {
    // 모든 셀이 채워졌는지 확인
    bool isFull = true;
    for (int i = 0; i < state.boardSize; i++) {
      for (int j = 0; j < state.boardSize; j++) {
        if (!state.board[i][j].hasNumber) {
          isFull = false;
          break;
        }
      }
      if (!isFull) break;
    }

    if (isFull && _isValidSolution()) {
      state = state.copyWith(isCompleted: true);
      debugPrint('Game completed!');
    }
  }

  /// 해답 유효성 검증 (기본적인 스도쿠 규칙)
  bool _isValidSolution() {
    // 행 검증
    for (int i = 0; i < state.boardSize; i++) {
      final numbers = <int>{};
      for (int j = 0; j < state.boardSize; j++) {
        final number = state.board[i][j].number;
        if (number != null) {
          if (numbers.contains(number)) return false;
          numbers.add(number);
        }
      }
    }

    // 열 검증
    for (int j = 0; j < state.boardSize; j++) {
      final numbers = <int>{};
      for (int i = 0; i < state.boardSize; i++) {
        final number = state.board[i][j].number;
        if (number != null) {
          if (numbers.contains(number)) return false;
          numbers.add(number);
        }
      }
    }

    // 3x3 박스 검증 (9x9 보드인 경우)
    if (state.boardSize == 9) {
      for (int boxRow = 0; boxRow < 3; boxRow++) {
        for (int boxCol = 0; boxCol < 3; boxCol++) {
          final numbers = <int>{};
          for (int i = boxRow * 3; i < (boxRow + 1) * 3; i++) {
            for (int j = boxCol * 3; j < (boxCol + 1) * 3; j++) {
              final number = state.board[i][j].number;
              if (number != null) {
                if (numbers.contains(number)) return false;
                numbers.add(number);
              }
            }
          }
        }
      }
    }

    return true;
  }

  /// 보드 깊은 복사
  List<List<CellContent>> _deepCopyBoard(List<List<CellContent>> board) {
    return board
        .map((row) => row
            .map((cell) => CellContent(
                  number: cell.number,
                  chessPiece: cell.chessPiece,
                  isInitial: cell.isInitial,
                  notes: Set<int>.from(cell.notes),
                ))
            .toList())
        .toList();
  }

  /// 경과 시간 업데이트 (외부에서 호출)
  void updateElapsedTime(Duration newTime) {
    if (!state.isPaused && !state.isCompleted) {
      state = state.copyWith(elapsedTime: newTime);
    }
  }
}
