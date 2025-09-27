import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';

/// 스도쿠 보드의 셀 위치를 나타내는 모델
@freezed
class Position with _$Position {
  const factory Position({
    required int row,
    required int col,
  }) = _Position;

  const Position._();

  /// 유효한 위치인지 확인 (0-8 범위)
  bool get isValid => row >= 0 && row < 9 && col >= 0 && col < 9;

  /// 같은 행에 있는지 확인
  bool isSameRow(Position other) => row == other.row;

  /// 같은 열에 있는지 확인
  bool isSameCol(Position other) => col == other.col;

  /// 같은 3x3 블록에 있는지 확인
  bool isSameBlock(Position other) {
    return (row ~/ 3) == (other.row ~/ 3) && (col ~/ 3) == (other.col ~/ 3);
  }

  /// 3x3 블록 인덱스 반환 (0-8)
  int get blockIndex => (row ~/ 3) * 3 + (col ~/ 3);

  /// 문자열에서 Position 생성 (예: "0,1" -> Position(0, 1))
  static Position fromString(String positionStr) {
    final parts = positionStr.split(',');
    return Position(
      row: int.parse(parts[0]),
      col: int.parse(parts[1]),
    );
  }
}
