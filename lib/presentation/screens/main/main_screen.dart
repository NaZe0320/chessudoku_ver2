// import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/di/game_provider.dart';
// import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/application/intents/main_intent.dart';
import 'package:chessudoku/application/intents/game_preparation_intent.dart';
import 'package:chessudoku/application/intents/game_intent.dart';
// import 'package:chessudoku/presentation/screens/main/widgets/quick_play_grid.dart';
// import 'package:chessudoku/presentation/screens/main/widgets/continue_play_card.dart';
import 'package:chessudoku/presentation/screens/main/widgets/home_menu_button.dart';
// import 'package:chessudoku/presentation/common/widgets/game_selection_dialog.dart';
import 'package:chessudoku/presentation/common/widgets/offline_dialog.dart';
import 'package:chessudoku/presentation/screens/game/game_screen.dart';
import 'package:chessudoku/presentation/screens/setting/settings_screen.dart';
import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final translate = ref.watch(translationProvider);
    final mainState = ref.watch(mainNotifierProvider);
    final mainNotifier = ref.read(mainNotifierProvider.notifier);
    final gamePreparationState = ref.watch(gamePreparationNotifierProvider);
    final gamePreparationNotifier =
        ref.read(gamePreparationNotifierProvider.notifier);

    // 화면 진입 시 저장된 게임 확인 (한 번만 실행)
    useEffect(() {
      mainNotifier.handleIntent(const CheckSavedGameIntent());

      return null;
    }, []);

    // 게임 준비 완료 처리 (새 게임만)
    useEffect(() {
      if (gamePreparationState.isReady &&
          gamePreparationState.preparedBoard != null) {
        // 게임 준비가 완료되면 GameScreen으로 이동 (새 게임만)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final gameNotifier = ref.read(gameNotifierProvider.notifier);

          // 새 게임 시작 시 난이도 설정 추가
          if (gamePreparationState.difficulty != null) {
            gameNotifier.setCurrentDifficulty(gamePreparationState.difficulty!);
          }

          // 새 게임 시작
          gameNotifier.handleIntent(
              StartGameIntent(gamePreparationState.preparedBoard!));

          // GameScreen으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameScreen(),
            ),
          ).then((_) {
            // 게임 시작 정보 초기화
            mainNotifier.handleIntent(const GetGameStartInfoIntent());
            // 게임 준비 상태 초기화
            gamePreparationNotifier.reset();
          });
        });
      } else if (gamePreparationState.error != null) {
        // 오류가 있는 경우
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (gamePreparationState.error != null) {
            // 인터넷 연결 관련 에러인지 확인
            if (gamePreparationState.error!.contains('OFFLINE_ERROR') ||
                gamePreparationState.error!.contains('인터넷 연결') ||
                gamePreparationState.error!.contains('온라인 상태')) {
              // 오프라인 다이얼로그 표시
              OfflineDialog.show(
                context: context,
                title: '인터넷 연결 필요',
                message: gamePreparationState.error!
                    .replaceAll('OFFLINE_ERROR: ', ''),
                onRetry: () {
                  // 게임 준비 재시도
                  if (gamePreparationState.difficulty != null) {
                    gamePreparationNotifier.handleIntent(
                      StartGamePreparationIntent(
                        difficulty: gamePreparationState.difficulty!,
                        isNewGame: true,
                      ),
                    );
                  }
                },
                onCancel: () {
                  // 게임 준비 상태 초기화
                  gamePreparationNotifier.reset();
                },
              );
            } else {
              // 일반 오류 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('게임 준비 실패: ${gamePreparationState.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
      }
      return null;
    }, [gamePreparationState.isReady, gamePreparationState.error]);

    // 저장된 게임 이어서 하기 처리 (통합된 방식)
    useEffect(() {
      if (mainState.shouldContinueGame && mainState.savedGameBoard != null) {
        // 저장된 게임 이어서 하기
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final gameNotifier = ref.read(gameNotifierProvider.notifier);

          // GameNotifier에 난이도 설정
          if (mainState.selectedDifficulty != null) {
            gameNotifier.setCurrentDifficulty(mainState.selectedDifficulty!);
          }

          // 저장된 게임 데이터로 게임 시작
          gameNotifier.handleIntent(const LoadSavedGameIntent());

          // GameScreen으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameScreen(),
            ),
          ).then((_) {
            // 게임 시작 정보 초기화
            mainNotifier.handleIntent(const GetGameStartInfoIntent());
          });
        });
      }
      return null;
    }, [mainState.shouldContinueGame, mainState.savedGameBoard]);

    // 로딩 상태 표시 (메인 로딩 또는 게임 준비 중)
    if (mainState.isLoading || gamePreparationState.isPreparing) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryLight,
                AppColors.primary,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                ),
                SizedBox(height: 16),
                Text(
                  '게임 준비 중...',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight,
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 상단 고정 설정 버튼
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: AppColors.textWhite,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // 본문 컨텐츠 (스크롤 제거, Expanded 배치)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 상단 영역: 중앙 아이콘 (가운데 정렬, 확장 없음)
                          Center(
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_view,
                                color: AppColors.primary,
                                size: 44,
                              ),
                            ),
                          ),

                          // 하단 영역: 3개의 컨테이너 버튼
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              HomeMenuButton(
                                leadingIcon: Icons.grid_view_rounded,
                                title: '새 게임',
                                subtitle: '난이도를 선택해 시작하기',
                                onTap: () {
                                  // 다음 단계에서 난이도 페이지 연결 예정
                                },
                              ),
                              HomeMenuButton(
                                leadingIcon: Icons.play_arrow_rounded,
                                title: '이어서 하기',
                                subtitle: mainState.hasSavedGame
                                    ? (mainState.savedGameInfo ?? '최근 기록 불러오기')
                                    : '저장된 게임이 없습니다',
                                enabled: mainState.hasSavedGame,
                                onTap: mainState.hasSavedGame
                                    ? () {
                                        // 저장된 게임 이어서 하기 실행
                                        mainNotifier.handleIntent(
                                            const ContinueSavedGameIntent());
                                      }
                                    : null,
                              ),
                              HomeMenuButton(
                                leadingIcon: Icons.emoji_events_rounded,
                                title: '데일리 챌린지',
                                subtitle: '오늘의 퍼즐 도전',
                                onTap: () {
                                  // 추후 연결
                                },
                              ),
                            ],
                          ),
                        ],
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
}
