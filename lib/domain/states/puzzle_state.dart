import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class PuzzleState {
  final Difficulty difficulty;
  final List<List<CellContent>> board; // 퍼즐 보드
  final int? selectedRow; // 선택된 행
  final int? selectedCol; // 선택된 열
  final bool isCompleted; // 게임 완료 여부
  final int boardSize; // 보드 크기
  final Duration elapsedTime; // 경과 시간
  final bool isTimerRunning; // 타이머 실행 상태

  const PuzzleState({
    this.difficulty = Difficulty.easy,
    this.board = const [],
    this.selectedRow,
    this.selectedCol,
    this.isCompleted = false,
    this.boardSize = 9,
    this.elapsedTime = Duration.zero,
    this.isTimerRunning = false,
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
    );
  }

  // 선택된 셀 내용
  CellContent? get selectedCell {
    if (selectedRow == null || selectedCol == null) return null;
    if (selectedRow! < 0 ||
        selectedRow! >= boardSize ||
        selectedCol! < 0 ||
        selectedCol! >= boardSize) return null;
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

  // 포맷된 타이머 시간 (mm:ss)
  String get formattedTime {
    final minutes =
        elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
