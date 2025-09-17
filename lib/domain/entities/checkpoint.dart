import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/entities/game_board.dart';

part 'checkpoint.freezed.dart';

/// 체크포인트 정보를 담는 모델
@freezed
class Checkpoint with _$Checkpoint {
  const factory Checkpoint({
    required GameBoard board,
    required int elapsedSeconds,
    required DateTime createdAt,
    required List<GameBoard> history,
    required List<GameBoard> redoHistory,
  }) = _Checkpoint;

  const Checkpoint._();

  /// 체크포인트 생성
  factory Checkpoint.create({
    required GameBoard board,
    required int elapsedSeconds,
    required List<GameBoard> history,
    required List<GameBoard> redoHistory,
  }) {
    return Checkpoint(
      board: board,
      elapsedSeconds: elapsedSeconds,
      createdAt: DateTime.now(),
      history: history,
      redoHistory: redoHistory,
    );
  }

  /// 진행 시간을 시:분:초 형태로 포맷
  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 진행 시간을 포맷된 문자열로 반환
  String get formattedElapsedTime => _formatTime(elapsedSeconds);
}
