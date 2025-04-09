// 저장된 퍼즐 상태를 나타내는 클래스
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/models/puzzle_action.dart';

class SavedPuzzleState {
  final DateTime createdAt;
  final List<List<CellContent>> board;
  final bool isNoteMode;
  final List<PuzzleAction> history;
  final int historyIndex;
  final Set<String> errorCells;

  SavedPuzzleState({
    required this.board,
    required this.isNoteMode,
    required this.history,
    required this.historyIndex,
    required this.errorCells,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 저장된 시간을 포맷팅하여 반환
  String get formattedCreatedAt {
    return '${createdAt.month}월 ${createdAt.day}일 ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
