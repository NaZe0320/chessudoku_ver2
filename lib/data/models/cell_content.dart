import 'package:chessudoku/domain/enums/chess_piece.dart';

class CellContent {
  final int? number; // 숫자 (1-9)
  final ChessPiece? chessPiece; // 체스 기물
  final bool isInitial; // 초기값 여부 (수정 불가능)
  final Set<int> notes; // 메모(노트) 숫자들

  const CellContent({
    this.number,
    this.chessPiece,
    this.isInitial = false,
    this.notes = const {},
  });

  // 깊은 복사를 위한 복사 생성자
  CellContent copyWith({
    int? number,
    ChessPiece? chessPiece,
    bool? isInitial,
    Set<int>? notes,
  }) {
    return CellContent(
      number: number ?? this.number,
      chessPiece: chessPiece ?? this.chessPiece,
      isInitial: isInitial ?? this.isInitial,
      notes: notes ?? this.notes,
    );
  }

  // 빈 셀인지 확인
  bool get isEmpty => number == null && chessPiece == null;

  // 숫자를 가지고 있는지 확인
  bool get hasNumber => number != null;

  // 체스 기물을 가지고 있는지 확인
  bool get hasChessPiece => chessPiece != null;

  // 메모(노트)가 있는지 확인
  bool get hasNotes => notes.isNotEmpty;

  // 특정 메모(노트)가 있는지 확인
  bool hasNote(int note) => notes.contains(note);

  // 메모(노트) 추가
  CellContent addNote(int note) {
    final newNotes = Set<int>.from(notes);
    newNotes.add(note);
    return copyWith(notes: newNotes);
  }

  // 메모(노트) 제거
  CellContent removeNote(int note) {
    final newNotes = Set<int>.from(notes);
    newNotes.remove(note);
    return copyWith(notes: newNotes);
  }

  // 메모(노트) 토글
  CellContent toggleNote(int note) {
    if (hasNote(note)) {
      return removeNote(note);
    } else {
      return addNote(note);
    }
  }

  // 모든 메모(노트) 지우기
  CellContent clearNotes() {
    return copyWith(notes: {});
  }
}
