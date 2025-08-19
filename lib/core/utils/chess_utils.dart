import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/core/enums/chess_piece.dart';

/// 체스 관련 유틸리티 함수들
class ChessUtils {
  /// 난이도에 따라 체스 기물을 반환
  static ChessPiece fromDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return ChessPiece.pawn;
      case Difficulty.medium:
        return ChessPiece.knight;
      case Difficulty.hard:
        return ChessPiece.bishop;
      case Difficulty.expert:
        return ChessPiece.queen;
    }
  }
}
