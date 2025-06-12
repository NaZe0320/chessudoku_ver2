import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:chessudoku/domain/states/puzzle_pack_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzlePackNotifier extends StateNotifier<PuzzlePackState> {
  final PuzzleRepository _puzzleRepository;

  PuzzlePackNotifier(this._puzzleRepository) : super(const PuzzlePackState());

  /// 퍼즐 팩 목록 로드
  Future<void> loadPuzzlePacks() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final puzzlePacks = await _puzzleRepository.getPuzzlePacks();
      state = state.copyWith(
        puzzlePacks: puzzlePacks,
        isLoading: false,
      );
      debugPrint('[PuzzlePackNotifier] 퍼즐 팩 로드 완료: ${puzzlePacks.length}개');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      debugPrint('[PuzzlePackNotifier] 퍼즐 팩 로드 실패: $error');
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  /// 상태 새로고침
  Future<void> refresh() async {
    await loadPuzzlePacks();
  }
}
