/// 스도쿠 보드의 셀 위치를 나타내는 모델
class Position {
  final int row; // 행 (0-8)
  final int col; // 열 (0-8)

  const Position({
    required this.row,
    required this.col,
  });

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

  /// Position 복사
  Position copyWith({
    int? row,
    int? col,
  }) {
    return Position(
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position(row: $row, col: $col)';
}
