import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/di/puzzle_provider.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/models/puzzle_action.dart';
import 'package:chessudoku/data/repositories/puzzle_repository.dart';
import 'package:chessudoku/data/repositories/record_repository.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/notifiers/puzzle_notifier.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:chessudoku/core/utils/chess_sudoku_generator.dart';
import 'package:chessudoku/core/utils/chess_sudoku_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleIntent {
  final Ref ref;

  PuzzleIntent(this.ref);

  // 노티파이어에 대한 참조를 쉽게 얻기 위한 getter
  PuzzleNotifier get _notifier => ref.read(puzzleNotifierProvider.notifier);

  // 레포지토리에 대한 참조를 쉽게 얻기 위한 getter
  PuzzleRepository get _repository => ref.read(puzzleRepositoryProvider);

  // 기록 레포지토리에 대한 참조를 쉽게 얻기 위한 getter
  RecordRepository get _recordRepository => ref.read(recordRepositoryProvider);

  // 체스도쿠 생성기에 대한 참조
  ChessSudokuGenerator get _generator => ref.read(chessSudokuGeneratorProvider);

  // 난이도 변경
  void changeDifficulty(Difficulty difficulty) {
    _notifier.changeDifficulty(difficulty);
  }

  // 게임 초기화 (새 게임 또는 저장된 게임)
  Future<void> initializeGame(Difficulty difficulty, {bool useSavedState = false}) async {
    // 타이머 중지
    _notifier.stopTimer();

    // useSavedState가 true이고 저장된 상태가 있는 경우에만 저장된 상태 불러오기
    if (useSavedState && _repository.hasCachedPuzzleState(difficulty)) {
      final savedState = await _repository.loadPuzzleState(difficulty);
      if (savedState != null) {
        // 저장된 상태로 초기화
        _notifier.initializeGameWithState(savedState);
        // 타이머 시작
        _notifier.startTimer();
        return;
      }
    }

    // 저장된 상태가 없거나 새 게임을 시작하는 경우
    const boardSize = ChessSudokuGenerator.boardSize;

    // 로딩 화면 실행행
    ref.read(loadingNotifierProvider.notifier).showLoading(message: '게임을 생성하는 중...');
    // 체스도쿠 생성기를 사용하여 보드 생성
    final gameBoard = await _generator.generatePuzzle(difficulty);

    // 상태 업데이트
    _notifier.initializeGameWithBoard(gameBoard: gameBoard, boardSize: boardSize);

    // 로딩 화면 종료료
    ref.read(loadingNotifierProvider.notifier).hideLoading();

    // 타이머 시작
    _notifier.startTimer();
  }

  // 현재 게임 상태를 캐시에 저장
  Future<bool> saveGameState() async {
    final currentState = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 저장하지 않음
    if (currentState.isCompleted) return false;

    return await _repository.savePuzzleState(currentState);
  }

  // 캐시에서 게임 상태 삭제
  Future<bool> clearSavedGameState([Difficulty? difficulty]) async {
    if (difficulty != null) {
      return await _repository.clearPuzzleState(difficulty);
    } else {
      final currentState = ref.read(puzzleProvider);
      return await _repository.clearPuzzleState(currentState.difficulty);
    }
  }

  // 저장된 게임이 있는지 확인
  bool hasSavedGame(Difficulty difficulty) {
    return _repository.hasCachedPuzzleState(difficulty);
  }

  // 셀 선택
  void selectCell(int row, int col) {
    _notifier.selectCell(row, col);
  }

  // 선택된 셀에 숫자 입력
  void enterNumber(int number) {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    if (state.selectedRow == null ||
        state.selectedCol == null ||
        state.isSelectedCellInitial ||
        state.board[state.selectedRow!][state.selectedCol!].hasChessPiece) {
      return;
    }

    if (number < 1 || number > state.boardSize) {
      return;
    }

    final row = state.selectedRow!;
    final col = state.selectedCol!;
    final oldContent = state.board[row][col];

    // 메모 모드인 경우
    if (state.isNoteMode) {
      final CellContent newContent = oldContent.toggleNote(number);

      // 액션 생성 및 히스토리에 추가
      final action = PuzzleAction(
        row: row,
        col: col,
        oldContent: oldContent,
        newContent: newContent,
      );

      final newState = state.addAction(action);

      // 보드 업데이트
      final newBoard = _deepCopyBoard(state.board);
      newBoard[row][col] = newContent;

      _notifier.updateBoardWithState(newBoard, newState);
    } else {
      // 일반 모드 - 숫자 입력 또는 제거
      // 이미 같은 숫자가 있는 경우 숫자 제거
      if (oldContent.hasNumber && oldContent.number == number) {
        const CellContent newContent = CellContent();

        // 액션 생성 및 히스토리에 추가
        final action = PuzzleAction(
          row: row,
          col: col,
          oldContent: oldContent,
          newContent: newContent,
        );

        final newState = state.addAction(action);

        // 보드 업데이트
        final newBoard = _deepCopyBoard(state.board);
        newBoard[row][col] = newContent;

        _notifier.updateBoardWithState(newBoard, newState, isCompleted: false);
      } else {
        // 다른 숫자를 입력하는 경우
        final CellContent newContent = CellContent(number: number);

        // 액션 생성 및 히스토리에 추가
        final action = PuzzleAction(
          row: row,
          col: col,
          oldContent: oldContent,
          newContent: newContent,
        );

        final newState = state.addAction(action);

        // 보드 업데이트
        final newBoard = _deepCopyBoard(state.board);
        newBoard[row][col] = newContent;

        final isCompleted = _checkCompletion(newBoard);

        _notifier.updateBoardWithState(newBoard, newState, isCompleted: isCompleted);

        if (isCompleted) {
          _notifier.stopTimer();
          // 퍼즐 완료 시 DB에 기록 저장
          _savePuzzleRecord();
          // 게임 완료 시 저장된 상태 삭제
          clearSavedGameState();
        }
      }
    }
  }

  // 퍼즐 완료 기록 저장
  Future<bool> _savePuzzleRecord() async {
    final state = ref.read(puzzleProvider);
    if (!state.isCompleted) {
      return false;
    }

    try {
      return await _recordRepository.savePuzzleRecord(state);
    } catch (e) {
      print('퍼즐 기록 저장 중 오류 발생: $e');
      return false;
    }
  }

  // 선택된 셀 값 삭제
  void clearValue() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    if (state.selectedRow == null ||
        state.selectedCol == null ||
        state.isSelectedCellInitial ||
        state.board[state.selectedRow!][state.selectedCol!].hasChessPiece) {
      return;
    }

    final row = state.selectedRow!;
    final col = state.selectedCol!;
    final oldContent = state.board[row][col];
    const CellContent newContent = CellContent();

    // 액션 생성 및 히스토리에 추가
    final action = PuzzleAction(
      row: row,
      col: col,
      oldContent: oldContent,
      newContent: newContent,
    );

    final newState = state.addAction(action);

    // 보드 업데이트
    final newBoard = _deepCopyBoard(state.board);
    newBoard[row][col] = newContent;

    _notifier.updateBoardWithState(newBoard, newState, isCompleted: false);
  }

  // 메모 모드 토글
  void toggleNoteMode() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    _notifier.toggleNoteMode();
  }

  // 오류 검사 모드 토글
  void checkErrors() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    _notifier.checkErrors();
  }

  // 되돌리기 액션
  void undoAction() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    if (!state.canUndo) return;

    final newState = state.undo();
    _notifier.updateState(newState);
  }

  // 다시 실행 액션
  void redoAction() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    if (!state.canRedo) return;

    final newState = state.redo();
    _notifier.updateState(newState);
  }

  // 특정 난이도의 모든 퍼즐 기록 조회
  Future<List<Map<String, dynamic>>> getRecordsByDifficulty(Difficulty difficulty) async {
    final records = await _recordRepository.getRecordsByDifficulty(difficulty);
    return records
        .map((record) => {
              'id': record.id,
              'difficulty': record.difficulty.name,
              'completionTime': record.formattedCompletionTime,
              'createdAt': record.createdAt.toString(),
            })
        .toList();
  }

  // 특정 난이도의 최고 기록 조회
  Future<Map<String, dynamic>?> getBestRecordByDifficulty(Difficulty difficulty) async {
    final record = await _recordRepository.getBestRecordByDifficulty(difficulty);
    if (record == null) {
      return null;
    }

    return {
      'id': record.id,
      'difficulty': record.difficulty.name,
      'completionTime': record.formattedCompletionTime,
      'createdAt': record.createdAt.toString(),
    };
  }

  // 보드의 깊은 복사 생성
  List<List<CellContent>> _deepCopyBoard(List<List<CellContent>> board) {
    return List.generate(
      board.length,
      (row) => List.generate(
        board[row].length,
        (col) => board[row][col].copyWith(),
      ),
    );
  }

  // 퍼즐 완료 여부 확인
  bool _checkCompletion(List<List<CellContent>> board) {
    return ChessSudokuValidator.isValidBoard(board);
  }

  // 타이머 일시정지
  void pauseTimer() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    _notifier.pauseTimer();
  }

  // 타이머 재개
  void resumeTimer() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    _notifier.resumeTimer();
  }

  // 메모 자동 채우기
  void fillNotes() {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 작동하지 않음
    if (state.isCompleted) return;

    final boardSize = state.boardSize;
    final board = state.board;

    // 보드의 깊은 복사 생성
    final newBoard = _deepCopyBoard(board);

    // 히스토리에 추가할 액션 목록
    List<PuzzleAction> actions = [];

    // 각 빈 셀에 대해 가능한 후보 숫자 계산
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        // 이미 숫자가 있거나 체스 기물이 있거나 초기 셀이면 건너뛰기
        if (board[row][col].hasNumber || board[row][col].hasChessPiece || board[row][col].isInitial) {
          continue;
        }

        // 현재 셀에 대한 가능한 후보 숫자 구하기
        Set<int> possibleNumbers = _getPossibleNumbers(board, row, col);

        // 기존 메모와 비교하여 액션 생성
        final oldContent = board[row][col];
        final newContent = CellContent(notes: possibleNumbers);

        if (oldContent.notes != possibleNumbers) {
          // 액션 생성
          final action = PuzzleAction(
            row: row,
            col: col,
            oldContent: oldContent,
            newContent: newContent,
          );

          actions.add(action);

          // 보드 업데이트
          newBoard[row][col] = newContent;
        }
      }
    }

    // 액션이 없으면 종료
    if (actions.isEmpty) {
      return;
    }

    // 액션들을 히스토리에 추가하여 새로운 상태 생성
    PuzzleState newState = state;
    for (final action in actions) {
      newState = newState.addAction(action);
    }

    // 상태 업데이트
    _notifier.updateBoard(newBoard, false);
  }

  // 특정 셀의 가능한 후보 숫자 계산
  Set<int> _getPossibleNumbers(List<List<CellContent>> board, int row, int col) {
    final boardSize = board.length;
    Set<int> allNumbers = Set.from(List.generate(boardSize, (i) => i + 1));
    Set<int> usedNumbers = {};

    // 같은 행에 있는 숫자 제외
    for (int c = 0; c < boardSize; c++) {
      if (board[row][c].hasNumber) {
        usedNumbers.add(board[row][c].number!);
      }
    }

    // 같은 열에 있는 숫자 제외
    for (int r = 0; r < boardSize; r++) {
      if (board[r][col].hasNumber) {
        usedNumbers.add(board[r][col].number!);
      }
    }

    // 같은 3x3 박스에 있는 숫자 제외
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (board[r][c].hasNumber) {
          usedNumbers.add(board[r][c].number!);
        }
      }
    }

    // 체스 기물 규칙에 의해 제외되는 숫자
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        // 체스 기물이 없으면 건너뛰기
        if (!board[r][c].hasChessPiece) continue;

        // 현재 셀이 기물의 공격 범위에 있는지 확인
        if (_canPieceAttack(board[r][c].chessPiece!, r, c, row, col)) {
          // 각 방향을 독립적으로 고려하기 위해, 해당 방향의 셀들 수집
          List<List<int>> attackedCells = _getAttackedCells(board[r][c].chessPiece!, r, c, row, col);

          // 같은 방향/패턴에 있는 모든 셀을 순회
          for (final cell in attackedCells) {
            final r2 = cell[0];
            final c2 = cell[1];

            // 자기 자신이거나 체스 기물이 있는 셀이면 건너뛰기
            if ((r2 == row && c2 == col) || board[r2][c2].hasChessPiece) {
              continue;
            }

            // 숫자가 없으면 건너뛰기
            if (!board[r2][c2].hasNumber) continue;

            // 이 숫자는 현재 셀에 놓을 수 없음
            usedNumbers.add(board[r2][c2].number!);
          }
        }
      }
    }

    // 사용 가능한 숫자 계산
    allNumbers.removeAll(usedNumbers);
    return allNumbers;
  }

  // 기물의 특정 방향/패턴에 있는 모든 셀 반환
  List<List<int>> _getAttackedCells(ChessPiece piece, int pieceRow, int pieceCol, int targetRow, int targetCol) {
    const boardSize = 9;
    List<List<int>> attackedCells = [];

    switch (piece) {
      case ChessPiece.knight:
        // 나이트는 L자 이동 패턴으로 공격하는 모든 셀 반환
        for (int r = 0; r < boardSize; r++) {
          for (int c = 0; c < boardSize; c++) {
            if (_canPieceAttack(piece, pieceRow, pieceCol, r, c)) {
              attackedCells.add([r, c]);
            }
          }
        }
        break;

      case ChessPiece.rook:
        // 룩은 같은 행/열에 있는 모든 셀 반환 (같은 방향만)
        if (pieceRow == targetRow) {
          // 같은 행의 셀들 (같은 방향만)
          final direction = targetCol > pieceCol ? 1 : -1;
          for (int c = 0; c < boardSize; c++) {
            // 같은 방향인지 확인
            if ((c - pieceCol) * direction > 0) {
              attackedCells.add([pieceRow, c]);
            }
          }
        } else if (pieceCol == targetCol) {
          // 같은 열의 셀들 (같은 방향만)
          final direction = targetRow > pieceRow ? 1 : -1;
          for (int r = 0; r < boardSize; r++) {
            // 같은 방향인지 확인
            if ((r - pieceRow) * direction > 0) {
              attackedCells.add([r, pieceCol]);
            }
          }
        }
        break;

      case ChessPiece.bishop:
        // 비숍은 같은 대각선에 있는 모든 셀 반환
        final rowDiff = targetRow - pieceRow;
        final colDiff = targetCol - pieceCol;

        // 같은 대각선에 있는지 확인
        if (rowDiff.abs() == colDiff.abs()) {
          // 해당 대각선의 모든 셀 추가 (동일 방향만)
          for (int r = 0; r < boardSize; r++) {
            for (int c = 0; c < boardSize; c++) {
              // 대각선에 있는지 확인 (같은 방향만)
              if ((r - pieceRow) * (targetRow - pieceRow) > 0 && // 같은 방향
                  (c - pieceCol) * (targetCol - pieceCol) > 0 && // 같은 방향
                  (r - pieceRow).abs() == (c - pieceCol).abs()) {
                // 대각선
                attackedCells.add([r, c]);
              }
            }
          }
        }
        break;

      case ChessPiece.queen:
        // 퀸은 룩 + 비숍의 공격 범위
        // 같은 행/열 (룩)
        if (pieceRow == targetRow) {
          // 같은 행의 셀들 (같은 방향만)
          final direction = targetCol > pieceCol ? 1 : -1;
          for (int c = 0; c < boardSize; c++) {
            // 같은 방향인지 확인
            if ((c - pieceCol) * direction > 0) {
              attackedCells.add([pieceRow, c]);
            }
          }
        } else if (pieceCol == targetCol) {
          // 같은 열의 셀들 (같은 방향만)
          final direction = targetRow > pieceRow ? 1 : -1;
          for (int r = 0; r < boardSize; r++) {
            // 같은 방향인지 확인
            if ((r - pieceRow) * direction > 0) {
              attackedCells.add([r, pieceCol]);
            }
          }
        }
        // 같은 대각선 (비숍)
        else {
          final rowDiff = targetRow - pieceRow;
          final colDiff = targetCol - pieceCol;
          if (rowDiff.abs() == colDiff.abs()) {
            // 해당 대각선의 모든 셀 추가 (동일 방향만)
            for (int r = 0; r < boardSize; r++) {
              for (int c = 0; c < boardSize; c++) {
                // 대각선에 있는지 확인 (같은 방향만)
                if ((r - pieceRow) * (targetRow - pieceRow) > 0 && // 같은 방향
                    (c - pieceCol) * (targetCol - pieceCol) > 0 && // 같은 방향
                    (r - pieceRow).abs() == (c - pieceCol).abs()) {
                  // 대각선
                  attackedCells.add([r, c]);
                }
              }
            }
          }
        }
        break;

      case ChessPiece.king:
        // 킹은 한 칸씩 모든 방향으로 이동 가능
        // 주변 8개 셀의 좌표를 확인하여 유효한 셀 추가
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            if (i == 0 && j == 0) continue; // 자기 자신은 제외
            final r = pieceRow + i;
            final c = pieceCol + j;
            if (r >= 0 && r < boardSize && c >= 0 && c < boardSize) {
              attackedCells.add([r, c]);
            }
          }
        }
        break;
    }

    return attackedCells;
  }

  // 체스 기물이 특정 위치를 공격할 수 있는지 확인
  bool _canPieceAttack(ChessPiece piece, int pieceRow, int pieceCol, int targetRow, int targetCol) {
    return ChessSudokuValidator.canPieceAttack(piece, pieceRow, pieceCol, targetRow, targetCol);
  }

  // 특정 슬롯의 저장 시점 정보 가져오기
  String? getSaveTimeInSlot(int slot) {
    final state = ref.read(puzzleProvider);
    if (!state.hasStateInSlot(slot)) return null;

    return state.savedStates[slot]?.formattedCreatedAt;
  }

  // 현재 상태를 특정 슬롯에 저장
  void saveToSlot(int slot) {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 저장하지 않음
    if (state.isCompleted) return;

    // 슬롯 범위 검사
    if (slot < 0 || slot > 2) return;

    final newState = state.saveToSlot(slot);
    _notifier.updateState(newState);
  }

  // 특정 슬롯에서 상태 불러오기
  void loadFromSlot(int slot) {
    final state = ref.read(puzzleProvider);

    // 이미 완료된 퍼즐이면 불러오지 않음
    if (state.isCompleted) return;

    // 슬롯 범위 검사
    if (slot < 0 || slot > 2) return;

    // 해당 슬롯에 저장된 상태가 없으면 무시
    if (!state.hasStateInSlot(slot)) return;

    final newState = state.loadFromSlot(slot);
    _notifier.updateState(newState);
  }

  // 특정 슬롯에 저장된 상태가 있는지 확인
  bool hasStateInSlot(int slot) {
    final state = ref.read(puzzleProvider);
    return state.hasStateInSlot(slot);
  }

  // 게임 시작 처리
  Future<bool?> handleStartGame(Difficulty difficulty) async {
    // 난이도 변경
    changeDifficulty(difficulty);

    // 선택한 난이도의 저장된 게임이 있는지 확인
    final hasSavedGame = this.hasSavedGame(difficulty);

    if (hasSavedGame) {
      return null; // UI에서 다이얼로그를 표시하도록 null 반환
    } else {
      // 저장된 게임이 없으면 새 게임 초기화
      await initializeGame(difficulty, useSavedState: false);
      return true; // 게임 화면으로 이동
    }
  }

  // 게임 이어하기 또는 새로 시작
  Future<void> continueOrStartNewGame(Difficulty difficulty, bool shouldContinue) async {
    if (shouldContinue) {
      // 이어하기 선택 - 저장된 데이터 사용
      await initializeGame(difficulty, useSavedState: true);
    } else {
      // 새로 시작 선택 - 저장된 데이터 삭제 후 시작
      await clearSavedGameState(difficulty);
      await initializeGame(difficulty, useSavedState: false);
    }
  }
}
