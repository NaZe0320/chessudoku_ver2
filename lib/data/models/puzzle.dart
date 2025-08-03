import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/data/models/position.dart';

/// Firestore에서 가져온 퍼즐 데이터 모델
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
        // 체스 기물 이모지가 포함된 경우 숫자만 추출
        if (cell.contains('♝') ||
            cell.contains('♗') ||
            cell.contains('♔') ||
            cell.contains('♕') ||
            cell.contains('♖') ||
            cell.contains('♘') ||
            cell.contains('♙')) {
          // 체스 기물 위치의 숫자는 null로 처리 (체스 기물이 있으므로)
          return null;
        }
        return int.parse(cell);
      }).toList();
    }).toList();
  }

  /// 2D 배열을 문자열로 변환
  static String _gridToString(List<List<int?>> grid) {
    return grid.map((row) {
      return row.map((cell) => cell?.toString() ?? 'null').join(',');
    }).join(';');
  }

  /// Firestore 문서에서 Puzzle 객체 생성
  factory Puzzle.fromFirestore(Map<String, dynamic> data, String documentId) {
    // 난이도 파싱
    final difficultyString = data['difficulty'] as String;
    final difficulty = Difficulty.values.firstWhere(
      (d) => d.name == difficultyString,
      orElse: () => Difficulty.medium,
    );

    // 퍼즐 데이터 파싱 (문자열에서 2D 배열로 변환)
    final puzzleString = data['puzzle'] as String;
    final puzzle = _parseGridString(puzzleString);

    // 솔루션 데이터 파싱 (문자열에서 2D 배열로 변환)
    final solutionString = data['solution'] as String;
    final solution = _parseGridString(solutionString);

    // 체스 기물 파싱
    final chessPiecesData = data['chessPieces'] as Map<String, dynamic>? ?? {};
    final chessPieces = <Position, ChessPiece>{};

    chessPiecesData.forEach((key, value) {
      final coords = key.split(',');
      if (coords.length == 2) {
        final row = int.parse(coords[0]);
        final col = int.parse(coords[1]);
        final position = Position(row: row, col: col);

        final pieceString = value as String;
        final piece = ChessPiece.values.firstWhere(
          (p) => p.name == pieceString,
          orElse: () => ChessPiece.queen,
        );

        chessPieces[position] = piece;
      }
    });

    // 생성일 파싱
    final createdAtString = data['createdAt'] as String;
    final createdAt = DateTime.parse(createdAtString);

    return Puzzle(
      puzzleId: documentId,
      difficulty: difficulty,
      puzzle: puzzle,
      solution: solution,
      chessPieces: chessPieces,
      createdAt: createdAt,
    );
  }

  /// Map으로 변환 (Firestore 저장용)
  Map<String, dynamic> toFirestore() {
    final chessPiecesMap = <String, String>{};
    chessPieces.forEach((position, piece) {
      chessPiecesMap['${position.row},${position.col}'] = piece.name;
    });

    return {
      'puzzleId': puzzleId,
      'difficulty': difficulty.name,
      'puzzle': _gridToString(puzzle),
      'solution': _gridToString(solution),
      'chessPieces': chessPiecesMap,
      'createdAt': createdAt.toIso8601String(),
    };
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
