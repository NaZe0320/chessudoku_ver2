import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/models/puzzle_action.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/states/saved_puzzle_state.dart';

class PuzzleState {
  final Difficulty difficulty;
  final List<List<CellContent>> board; // 퍼즐 보드
  final int? selectedRow; // 선택된 행
  final int? selectedCol; // 선택된 열
  final bool isCompleted; // 게임 완료 여부
  final int boardSize; // 보드 크기
  final Duration elapsedTime; // 경과 시간
  final bool isTimerRunning; // 타이머 실행 상태
  final bool isNoteMode; // 메모 모드 여부
  final List<PuzzleAction> history; // 동작 히스토리
  final int historyIndex; // 현재 히스토리 인덱스
  final Set<String> errorCells; // 오류가 있는 셀 좌표 (row,col 형식)
  final Map<int, SavedPuzzleState> savedStates; // 저장된 분기점 상태 (슬롯별)

  const PuzzleState({
    this.difficulty = Difficulty.easy,
    this.board = const [],
    this.selectedRow,
    this.selectedCol,
    this.isCompleted = false,
    this.boardSize = 9,
    this.elapsedTime = Duration.zero,
    this.isTimerRunning = false,
    this.isNoteMode = false,
    this.history = const [],
    this.historyIndex = -1,
    this.errorCells = const {},
    this.savedStates = const {},
  });

  PuzzleState copyWith({
    Difficulty? difficulty,
    List<List<CellContent>>? board,
    int? selectedRow,
    int? selectedCol,
    bool? isCompleted,
    int? boardSize,
    Duration? elapsedTime,
    bool? isTimerRunning,
    bool? isNoteMode,
    List<PuzzleAction>? history,
    int? historyIndex,
    Set<String>? errorCells,
    Map<int, SavedPuzzleState>? savedStates,
  }) {
    return PuzzleState(
      difficulty: difficulty ?? this.difficulty,
      board: board ?? this.board,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      isCompleted: isCompleted ?? this.isCompleted,
      boardSize: boardSize ?? this.boardSize,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      errorCells: errorCells ?? this.errorCells,
      savedStates: savedStates ?? this.savedStates,
    );
  }

  // 선택된 셀 내용
  CellContent? get selectedCell {
    if (selectedRow == null || selectedCol == null) return null;
    if (selectedRow! < 0 ||
        selectedRow! >= boardSize ||
        selectedCol! < 0 ||
        selectedCol! >= boardSize) {
      return null;
    }
    return board[selectedRow!][selectedCol!];
  }

  // 선택된 셀이 초기값인지 확인
  bool get isSelectedCellInitial {
    return selectedCell?.isInitial ?? false;
  }

  // 선택된 셀이 비어있는지 확인
  bool get isSelectedCellEmpty {
    return selectedCell?.isEmpty ?? true;
  }

  // 선택된 셀이 오류가 있는지 확인
  bool get isSelectedCellError {
    if (selectedRow == null || selectedCol == null) return false;
    return errorCells.contains('$selectedRow,$selectedCol');
  }

  // 포맷된 타이머 시간 (mm:ss)
  String get formattedTime {
    final minutes =
        elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // 되돌리기 가능 여부
  bool get canUndo => historyIndex >= 0;

  // 다시 실행 가능 여부
  bool get canRedo => historyIndex < history.length - 1;

  // 히스토리에 동작 추가
  PuzzleState addAction(PuzzleAction action) {
    // 히스토리 중간에 있는 경우 이후 히스토리를 잘라냄
    final newHistory =
        List<PuzzleAction>.from(history.sublist(0, historyIndex + 1));
    newHistory.add(action);

    return copyWith(
      history: newHistory,
      historyIndex: historyIndex + 1,
    );
  }

  // 되돌리기 수행
  PuzzleState undo() {
    if (!canUndo) return this;

    final action = history[historyIndex];
    final newBoard = List<List<CellContent>>.from(board);
    newBoard[action.row][action.col] = action.oldContent;

    return copyWith(
      board: newBoard,
      historyIndex: historyIndex - 1,
    );
  }

  // 다시 실행 수행
  PuzzleState redo() {
    if (!canRedo) return this;

    final action = history[historyIndex + 1];
    final newBoard = List<List<CellContent>>.from(board);
    newBoard[action.row][action.col] = action.newContent;

    return copyWith(
      board: newBoard,
      historyIndex: historyIndex + 1,
    );
  }

  // 메모 모드 토글
  PuzzleState toggleNoteMode() {
    return copyWith(isNoteMode: !isNoteMode);
  }

  // 현재 상태를 특정 슬롯에 저장
  PuzzleState saveToSlot(int slot) {
    if (slot < 0 || slot > 2) return this; // 슬롯은 0-2까지만 허용

    final savedState = SavedPuzzleState(
      board: List.generate(
        boardSize,
        (row) => List.generate(
          boardSize,
          (col) => board[row][col].copyWith(),
        ),
      ),
      isNoteMode: isNoteMode,
      history: List.from(history),
      historyIndex: historyIndex,
      errorCells: Set.from(errorCells),
    );

    final newSavedStates = Map<int, SavedPuzzleState>.from(savedStates);
    newSavedStates[slot] = savedState;

    return copyWith(savedStates: newSavedStates);
  }

  // 특정 슬롯에서 상태 불러오기
  PuzzleState loadFromSlot(int slot) {
    if (slot < 0 || slot > 2) return this; // 슬롯은 0-2까지만 허용

    final savedState = savedStates[slot];
    if (savedState == null) return this;

    return copyWith(
      board: List.generate(
        boardSize,
        (row) => List.generate(
          boardSize,
          (col) => savedState.board[row][col].copyWith(),
        ),
      ),
      isNoteMode: savedState.isNoteMode,
      history: List.from(savedState.history),
      historyIndex: savedState.historyIndex,
      errorCells: Set.from(savedState.errorCells),
    );
  }

  // 특정 슬롯에 저장된 상태가 있는지 확인
  bool hasStateInSlot(int slot) {
    return savedStates.containsKey(slot);
  }
}