import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/core/enums/chess_piece.dart';

part 'cell_content.freezed.dart';

@freezed
class CellContent with _$CellContent {
  const factory CellContent({
    int? number,
    ChessPiece? chessPiece,
    @Default(false) bool isInitial,
    @Default({}) Set<int> notes,
  }) = _CellContent;

  const CellContent._();

  /// 빈 셀인지 확인
  bool get isEmpty => number == null && chessPiece == null;

  /// 숫자를 가지고 있는지 확인
  bool get hasNumber => number != null;

  /// 체스 기물을 가지고 있는지 확인
  bool get hasChessPiece => chessPiece != null;

  /// 메모(노트)가 있는지 확인
  bool get hasNotes => notes.isNotEmpty;

  /// 특정 메모(노트)가 있는지 확인
  bool hasNote(int note) => notes.contains(note);

  /// 메모(노트) 추가
  CellContent addNote(int note) => copyWith(notes: {...notes, note});

  /// 메모(노트) 제거
  CellContent removeNote(int note) =>
      copyWith(notes: notes.where((n) => n != note).toSet());

  /// 메모(노트) 토글
  CellContent toggleNote(int note) =>
      hasNote(note) ? removeNote(note) : addNote(note);

  /// 모든 메모(노트) 지우기
  CellContent clearNotes() => copyWith(notes: {});
}
