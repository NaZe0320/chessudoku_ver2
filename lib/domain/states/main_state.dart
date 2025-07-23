import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_state.freezed.dart';

@freezed
class MainState with _$MainState {
  const factory MainState({
    @Default(false) bool isLoading,
    @Default(false) bool hasSavedGame,
    String? savedGameInfo, // 저장된 게임 정보 (예: "보통 난이도 • 8번 정답 • 65% 완료")
    @Default(0) int completedPuzzles, // 완료한 퍼즐 수
    @Default(0) int currentStreak, // 현재 연속 기록
  }) = _MainState;
}
