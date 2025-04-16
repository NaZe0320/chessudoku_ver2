enum ChessPiece {
  king, // 킹
  queen, // 퀸
  rook, // 룩
  bishop, // 비숍
  knight; // 나이트

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
    }
  }
}
