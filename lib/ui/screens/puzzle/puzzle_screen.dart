import 'dart:ui';

import 'package:chessudoku/core/di/puzzle_provider.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_board.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_controls.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_header.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_keypad.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_timer.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key});

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 게임은 이미 PuzzlePage에서 초기화되어 있으므로 여기서는 타이머만 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(puzzleIntentProvider).resumeTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final puzzleIntent = ref.read(puzzleIntentProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        // 앱이 다시 활성화될 때 타이머 재개
        puzzleIntent.resumeTimer();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // 백그라운드로 갈 때 타이머 정지 및 상태 저장
        puzzleIntent.pauseTimer();
        puzzleIntent.saveGameState();
        break;
    }
  }

  // 뒤로가기 버튼 처리를 위한 메소드
  Future<bool> _onWillPop() async {
    final puzzleIntent = ref.read(puzzleIntentProvider);
    // 게임 상태 저장
    puzzleIntent.pauseTimer();
    puzzleIntent.saveGameState();
    return true; // true를 반환하여 뒤로가기 허용
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(puzzleProvider);
    final puzzleIntent = ref.read(puzzleIntentProvider);

    // 상태 변경 리스너 추가 - build 메소드 내에서 ref.listen 사용
    ref.listen<PuzzleState>(puzzleProvider, (previous, next) {
      // 완료 상태로 변경되었을 때 대화상자 표시
      if (previous != null &&
          previous.isCompleted == false &&
          next.isCompleted) {
        _showCompletionDialog(next);
      }
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          centerTitle: true,
          title: const Text(
            '체스도쿠',
            style: TextStyle(
              color: AppColors.neutral100,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.neutral100),
            onPressed: () {
              // 뒤로 가기 시 게임 상태 저장
              puzzleIntent.saveGameState();
              Navigator.pop(context);
            },
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: PuzzleTimer(),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(13),
          ),
          child: Stack(
            children: [
              const SafeArea(
                child: Column(
                  children: [
                    // 헤더 - 난이도 및 완료 메시지
                    PuzzleHeader(),
                    SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            PuzzleBoard(),
                            SizedBox(height: 12),
                            // 난이도 선택 및 게임 제어 버튼
                            PuzzleControls(),
                            SizedBox(height: 12),
                            // 숫자 키패드
                            PuzzleKeypad(),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!puzzleState.isTimerRunning && !puzzleState.isCompleted)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 0.98,
                  child: Container(
                    color: AppColors.neutral900.withAlpha(230),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Center(
                        child: Card(
                          elevation: 8,
                          shadowColor: AppColors.primary.withAlpha(153),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                              vertical: 24.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.pause_circle_filled,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '일시정지',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => puzzleIntent.resumeTimer(),
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('게임 재개'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.neutral100,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 퍼즐 완료 대화상자 표시
  void _showCompletionDialog(PuzzleState state) {
    final time = state.formattedTime;
    final difficulty = state.difficulty.name;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('축하합니다!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.primary,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text('체스도쿠를 성공적으로 해결했습니다!'),
              const SizedBox(height: 16),
              Text(
                '난이도: ${difficulty.substring(0, 1).toUpperCase()}${difficulty.substring(1)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '소요 시간: $time',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.neutral100,
        );
      },
    );
  }
}
