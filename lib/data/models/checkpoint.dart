import 'package:chessudoku/data/models/game_board.dart';

/// 체크포인트 정보를 담는 모델
class Checkpoint {
  final GameBoard board; // 해당 시점의 보드 상태
  final int elapsedSeconds; // 해당 시점까지의 진행 시간 (초)
  final DateTime createdAt; // 체크포인트 생성 시점
  final List<GameBoard> history; // 해당 시점의 히스토리
  final List<GameBoard> redoHistory; // 해당 시점의 redo 히스토리

  const Checkpoint({
    required this.board,
    required this.elapsedSeconds,
    required this.createdAt,
    required this.history,
    required this.redoHistory,
  });

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

  /// 체크포인트 복사
  Checkpoint copyWith({
    GameBoard? board,
    int? elapsedSeconds,
    DateTime? createdAt,
    List<GameBoard>? history,
    List<GameBoard>? redoHistory,
  }) {
    return Checkpoint(
      board: board ?? this.board,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      createdAt: createdAt ?? this.createdAt,
      history: history ?? this.history,
      redoHistory: redoHistory ?? this.redoHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Checkpoint &&
        other.board == board &&
        other.elapsedSeconds == elapsedSeconds &&
        other.createdAt == createdAt &&
        other.history == history &&
        other.redoHistory == redoHistory;
  }

  @override
  int get hashCode {
    return board.hashCode ^
        elapsedSeconds.hashCode ^
        createdAt.hashCode ^
        history.hashCode ^
        redoHistory.hashCode;
  }

  @override
  String toString() {
    return 'Checkpoint(elapsedSeconds: $elapsedSeconds, createdAt: $createdAt)';
  }
}
