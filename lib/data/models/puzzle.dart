import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/models/position.dart';
import 'package:flutter/foundation.dart';

/// 퍼즐 데이터 모델
class Puzzle {
  final String puzzleId;
  final Difficulty difficulty;
  final List<List<int?>> puzzle; // 빈칸이 있는 퍼즐
  final List<List<int?>> solution; // 완성된 답안
  final Map<Position, ChessPiece> chessPieces; // 체스 기물 배치
  final DateTime createdAt;

  const Puzzle({
    required this.puzzleId,
    required this.difficulty,
    required this.puzzle,
    required this.solution,
    required this.chessPieces,
    required this.createdAt,
  });

  /// 문자열을 2D 배열로 변환 (세미콜론과 쉼표로 구분)
  static List<List<int?>> _parseGridString(String gridString) {
    final rows = gridString.split(';');
    return rows.map((row) {
      return row.split(',').map((cell) {
        if (cell == 'null') return null;

        // 체스 기물 이모지가 포함된 경우 null로 처리
        // 모든 체스 기물 이모지 패턴 확인
        if (cell.contains('♔') ||
            cell.contains('♕') ||
            cell.contains('♖') ||
            cell.contains('♗') ||
            cell.contains('♘') ||
            cell.contains('♙') ||
            cell.contains('♚') ||
            cell.contains('♛') ||
            cell.contains('♜') ||
            cell.contains('♝') ||
            cell.contains('♞') ||
            cell.contains('♟')) {
          return null;
        }

        // 숫자가 아닌 문자가 포함된 경우 null로 처리
        try {
          return int.parse(cell);
        } catch (e) {
          debugPrint('Puzzle: 숫자 파싱 실패 - "$cell"');
          return null;
        }
      }).toList();
    }).toList();
  }

  /// 2D 배열을 문자열로 변환
  static String _gridToString(List<List<int?>> grid) {
    return grid.map((row) {
      return row.map((cell) => cell?.toString() ?? 'null').join(',');
    }).join(';');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Puzzle &&
        other.puzzleId == puzzleId &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return puzzleId.hashCode ^ difficulty.hashCode;
  }

  @override
  String toString() {
    return 'Puzzle(puzzleId: $puzzleId, difficulty: $difficulty)';
  }
}
