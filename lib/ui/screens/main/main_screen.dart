import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/intents/main_intent.dart';
import 'package:chessudoku/domain/intents/game_preparation_intent.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/ui/screens/main/widgets/quick_play_grid.dart';
import 'package:chessudoku/ui/screens/main/widgets/continue_play_card.dart';
import 'package:chessudoku/ui/screens/main/widgets/daily_challenge_card.dart';
import 'package:chessudoku/ui/common/widgets/stat_card.dart';
import 'package:chessudoku/ui/common/widgets/game_selection_dialog.dart';
import 'package:chessudoku/ui/common/widgets/offline_dialog.dart';
import 'package:chessudoku/ui/screens/game/game_screen.dart';
import 'package:chessudoku/ui/screens/profile/settings_screen.dart';
import 'package:chessudoku/ui/screens/profile/game_records_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);
    final mainState = ref.watch(mainNotifierProvider);
    final mainNotifier = ref.read(mainNotifierProvider.notifier);
    final gamePreparationState = ref.watch(gamePreparationNotifierProvider);
    final gamePreparationNotifier =
        ref.read(gamePreparationNotifierProvider.notifier);

    // 화면 진입 시 저장된 게임 확인 및 통계 로드 (한 번만 실행)
    useEffect(() {
      mainNotifier.handleIntent(const CheckSavedGameIntent());
      mainNotifier.handleIntent(const LoadStatsIntent());

      // GameNotifier에 MainNotifier 업데이트 콜백 설정
      final gameNotifier = ref.read(gameNotifierProvider.notifier);
      gameNotifier.setOnMainIntent((intent) {
        mainNotifier.handleIntent(intent);
      });

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
            // 게임 화면에서 돌아올 때 통계 새로고침
            mainNotifier.handleIntent(const LoadStatsIntent());
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
            // 게임 화면에서 돌아올 때 통계 새로고침
            mainNotifier.handleIntent(const LoadStatsIntent());
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
                AppColors.primary,
                AppColors.primaryLight,
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
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 앱 이름과 설정
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('app_name', 'ChesSudoku'),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
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
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 사용자 환영 메시지
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.textWhite,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate('welcome_back', '다시 오신 것을 환영합니다!'),
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              translate('keep_playing', '오늘도 퍼즐을 풀어보세요!'),
                              style: TextStyle(
                                color:
                                    AppColors.textWhite.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 통계 카드들 (사용자 프로필 데이터 사용)
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: mainState.completedPuzzles.toString(),
                        label: translate('completed_puzzles', '완료한 퍼즐'),
                        icon: Icons.check_circle,
                        onTap: () {
                          // 게임 기록 화면으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameRecordsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: '${mainState.currentStreak}일',
                        label: translate('current_streak', '연속 기록'),
                        icon: Icons.local_fire_department,
                        onTap: () {
                          // 통계 새로고침 (테스트용)
                          mainNotifier.handleIntent(const RefreshStatsIntent());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '통계 새로고침 완료: ${mainState.currentStreak}일 연속 (최고: ${mainState.bestStreak}일)'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 이어서 플레이 카드 (저장된 게임이 있을 때만 표시)
                if (mainState.hasSavedGame) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ContinuePlayCard(
                      title: translate('continue_playing', '이어서 플레이'),
                      subtitle: mainState.savedGameInfo ??
                          '${translate('normal_difficulty', '보통 난이도')} • ${translate('time_00_00', '00:00')}',
                      progressText: '',
                      progressValue: 0.0,
                      difficulty: Difficulty.medium,
                      onTap: () {
                        // 통합된 방식으로 저장된 게임 이어서 하기
                        mainNotifier
                            .handleIntent(const ContinueSavedGameIntent());
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 일일 챌린지 카드
                DailyChallengeCard(
                  title: translate('daily_challenge', '일일 챌린지'),
                  streakText: translate('may_streak', '7월 3째주'),
                  statusText: translate('challenge_status', '이번 주 진행 상황'),
                  messageText: translate(
                      'special_puzzle_message', '매일 특별한 퍼즐로 연속 기록을 쌓아보세요!'),
                  onDayTap: (day) {
                    // TODO: 데일리 챌린지 게임 준비 로직 구현
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    ).then((_) {
                      // 게임 화면에서 돌아올 때 통계 새로고침
                      mainNotifier.handleIntent(const LoadStatsIntent());
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 빠른 플레이 섹션
                Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      color: AppColors.textWhite,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      translate('quick_play', '빠른 플레이'),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  translate(
                      'quick_play_subtitle', '난이도를 선택해 바로 시작할 수 있는 새로운 퍼즐'),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // 빠른 플레이 버튼 그리드
                QuickPlayGrid(
                  onQuickPlayTap: (difficulty) {
                    // 저장된 게임이 있는지 확인
                    final gameSaveRepository =
                        ref.read(gameSaveRepositoryProvider);
                    gameSaveRepository
                        .hasSavedGameByDifficulty(difficulty)
                        .then((hasSavedGame) {
                      if (hasSavedGame) {
                        // 저장된 게임이 있으면 진행시간을 가져와서 선택 다이얼로그 표시
                        final savedGameData = gameSaveRepository
                            .getSavedGameByDifficulty(difficulty);
                        if (savedGameData != null) {
                          // 진행시간을 분:초 형식으로 변환
                          final minutes = savedGameData.elapsedSeconds ~/ 60;
                          final seconds = savedGameData.elapsedSeconds % 60;
                          final elapsedTimeString =
                              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                          GameSelectionDialog.show(
                            context: context,
                            title: '게임 선택',
                            message: '이미 진행 중인 게임이 있습니다. 어떻게 하시겠습니까?',
                            difficulty: difficulty,
                            elapsedTime: elapsedTimeString,
                            onContinueGame: () {
                              // 통합된 방식으로 저장된 게임 이어서 하기
                              mainNotifier.handleIntent(
                                ContinueSavedGameIntent(difficulty),
                              );
                            },
                            onNewGame: () {
                              // 새 게임 시작
                              gamePreparationNotifier.handleIntent(
                                StartGamePreparationIntent(
                                  difficulty: difficulty,
                                  isNewGame: true,
                                ),
                              );
                            },
                          );
                        }
                      } else {
                        // 저장된 게임이 없으면 바로 새 게임 시작
                        gamePreparationNotifier.handleIntent(
                          StartGamePreparationIntent(
                            difficulty: difficulty,
                            isNewGame: true,
                          ),
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
