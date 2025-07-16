import 'package:chessudoku/domain/enums/difficulty.dart';

enum ChessPiece {
  king, // 킹
  queen, // 퀸
  rook, // 룩
  bishop, // 비숍
  knight, // 나이트
  pawn; // 폰

  // 체스 기물을 문자로 변환 (UI 표시용)
  String get symbol {
    switch (this) {
      case ChessPiece.king:
        return '♚';
      case ChessPiece.queen:
        return '♛';
      case ChessPiece.rook:
        return '♜';
      case ChessPiece.bishop:
        return '♝';
      case ChessPiece.knight:
        return '♞';
      case ChessPiece.pawn:
        return '♟';
    }
  }

  // 난이도에 따라 체스 기물을 반환
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
