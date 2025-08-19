import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/core/enums/chess_piece.dart';
import 'package:chessudoku/domain/entities/position.dart';
import 'package:flutter/foundation.dart';

part 'puzzle.freezed.dart';

/// 퍼즐 데이터 모델
@freezed
class Puzzle with _$Puzzle {
  const factory Puzzle({
    required String puzzleId,
    required Difficulty difficulty,
    required List<List<int?>> puzzle,
    required List<List<int?>> solution,
    required Map<Position, ChessPiece> chessPieces,
    required DateTime createdAt,
  }) = _Puzzle;

  const Puzzle._();
}
