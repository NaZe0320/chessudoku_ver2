import 'package:flutter/foundation.dart';

@immutable
class SyncState {
  final double progress;
  final String message;
  final bool isCompleted;

  const SyncState({
    this.progress = 0.0,
    this.message = '초기화 중...',
    this.isCompleted = false,
  });

  SyncState copyWith({
    double? progress,
    String? message,
    bool? isCompleted,
  }) {
    return SyncState(
      progress: progress ?? this.progress,
      message: message ?? this.message,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
