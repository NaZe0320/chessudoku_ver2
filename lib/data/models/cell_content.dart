import 'package:chessudoku/domain/enums/chess_piece.dart';

class CellContent {
  final int? number; // 숫자 (1-9)
  final ChessPiece? chessPiece; // 체스 기물
  final bool isInitial; // 초기값 여부 (수정 불가능)

  const CellContent({
    this.number,
    this.chessPiece,
    this.isInitial = false,
  });

  // 깊은 복사를 위한 복사 생성자
  CellContent copyWith({
    int? number,
    ChessPiece? chessPiece,
    bool? isInitial,
  }) {
    return CellContent(
      number: number ?? this.number,
      chessPiece: chessPiece ?? this.chessPiece,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  // 빈 셀인지 확인
  bool get isEmpty => number == null && chessPiece == null;

  // 숫자를 가지고 있는지 확인
  bool get hasNumber => number != null;

  // 체스 기물을 가지고 있는지 확인
  bool get hasChessPiece => chessPiece != null;
}