import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/data/models/game_board.dart';

part 'game_preparation_state.freezed.dart';

@freezed
class GamePreparationState with _$GamePreparationState {
  const factory GamePreparationState({
    @Default(false) bool isPreparing,
    @Default(false) bool isReady,
    String? error,
    GameBoard? preparedBoard,
    String? puzzleId,
    Difficulty? difficulty,
  }) = _GamePreparationState;
}
