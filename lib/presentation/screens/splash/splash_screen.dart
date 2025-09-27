import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/initialization/app_initializer.dart';
import 'package:chessudoku/application/intents/main_intent.dart';
import 'package:chessudoku/application/intents/user_intent.dart';
import 'package:chessudoku/presentation/screens/main/main_screen.dart';
import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:chessudoku/presentation/screens/tutorial/tutorial_screen.dart';
import 'package:chessudoku/presentation/screens/offline/offline_warning_screen.dart';
import 'package:chessudoku/presentation/screens/error/server_error_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 애니메이션 컨트롤러들을 훅으로 생성
    final logoController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    final progressController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    // 애니메이션 정의
    final logoAnimation = useMemoized(
      () => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: logoController,
        curve: Curves.elasticOut,
      )),
      [logoController],
    );

    final progressAnimation = useMemoized(
      () => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: progressController,
        curve: Curves.easeInOut,
      )),
      [progressController],
    );

    // opacity를 안전하게 처리하는 함수들
    double getLogoOpacity() => (logoAnimation.value).clamp(0.0, 1.0);
    double getLogoScale() => logoAnimation.value.clamp(0.0, 1.0);
    double getDescriptionOpacity() =>
        (logoAnimation.value * 0.8).clamp(0.0, 1.0);
    double getProgressOpacity() => progressAnimation.value.clamp(0.0, 1.0);

    // 초기화 및 애니메이션 시작
    useEffect(() {
      // 애니메이션 시작
      logoController.forward();

      // 프레임 후 진행
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        progressController.forward();

        // AppInitializer를 통한 통합 초기화
        await _performInitialization(context, ref);
      });

      return null;
    }, []);

    final translate = ref.watch(translationProvider);

    // syncNotifierProvider를 listen하여 상태 변경 시 UI를 다시 빌드하고,
    // 동기화 완료 시 화면을 전환합니다.
    ref.listen(syncNotifierProvider, (previous, next) async {
      if (next.isCompleted) {
        // 동기화 완료 후 저장된 언어 설정 복원
        try {
          await ref
              .read(languagePackNotifierProvider.notifier)
              .restoreLanguageSettings();
          debugPrint('[SplashScreen] 언어 설정 복원 완료');
        } catch (e) {
          debugPrint('[SplashScreen] 언어 설정 복원 실패: $e');
        }

        // mounted 체크 후 네비게이션
        if (!context.mounted) return;

        // 튜토리얼 완료 여부 확인 후 분기
        final cache = ref.read(cacheServiceProvider);
        final completed = cache.getBool('tutorial_completed') ?? false;
        if (!completed) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TutorialScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        }
      }
    });

    // 동기화 상태를 화면에 표시합니다.
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // 로고 애니메이션
                AnimatedBuilder(
                  animation: logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: getLogoScale(),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.grid_view,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 앱 이름
                AnimatedBuilder(
                  animation: logoAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: getLogoOpacity(),
                      child: Text(
                        translate('app_name', 'ChesSudoku'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 앱 설명
                AnimatedBuilder(
                  animation: logoAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: getDescriptionOpacity(),
                      child: Text(
                        translate('app_description', '체스와 스도쿠의 만남'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                            ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),

                // 로딩 섹션
                AnimatedBuilder(
                  animation: progressAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: getProgressOpacity(),
                      child: Column(
                        children: [
                          // 커스텀 로딩 인디케이터
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accent,
                              ),
                              backgroundColor:
                                  AppColors.textWhite.withValues(alpha: 0.2),
                              strokeWidth: 3,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 상태 텍스트
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textWhite.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.textWhite.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              translate(
                                syncState.message
                                    .toLowerCase()
                                    .replaceAll(' ', '_'),
                                syncState.message,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 프로그레스 바
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.textWhite.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: syncState.progress,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 프로그레스 퍼센트
                          Text(
                            '${(syncState.progress * 100).toInt()}%',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textWhite
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 통합된 초기화 수행
  Future<void> _performInitialization(
      BuildContext context, WidgetRef ref) async {
    try {
      debugPrint('[SplashScreen] 통합 초기화 시작');

      // Repository 인스턴스 가져오기
      final gameSaveRepository = ref.read(gameSaveRepositoryProvider);
      // userProfileRepository 제거됨

      // AppInitializer를 통한 초기화
      final appInitializer = ref.read(appInitializerProvider);
      final result = await appInitializer.initialize(
        gameSaveRepository: gameSaveRepository,
      );

      debugPrint('[SplashScreen] 초기화 결과: $result');

      // 사용자 초기화 (기본 초기화와 별개로 진행) - 테스트용 로그 추가
      debugPrint('👤 [TEST] 스플래시에서 사용자 초기화 시작');
      final userNotifier = ref.read(userNotifierProvider.notifier);
      final userResult = await userNotifier.handleIntent(InitializeUserIntent());
      final user = ref.read(userNotifierProvider);

      debugPrint(
          '📊 [TEST] 사용자 초기화 결과: ${userResult?.status ?? "null"} - ${user?.userId ?? "null"}');

      switch (result) {
        case InitializationResult.success:
          // 사용자 초기화 결과에 따른 분기 처리
          if (userResult != null && userResult.isSuccess && user != null) {
            debugPrint('✅ [TEST] 앱 및 사용자 초기화 성공 - 메인으로 진행 (user: ${user.userId})');

            // 성공 시 동기화 시작
            ref.read(syncNotifierProvider.notifier).startSync();

            // MainNotifier 상태 초기화
            ref
                .read(mainNotifierProvider.notifier)
                .handleIntent(const CheckSavedGameIntent());
          } else if (userResult != null && userResult.isNetworkError) {
            debugPrint('📴 [TEST] 네트워크 오류 - 오프라인 화면으로 이동');
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfflineWarningScreen(),
                ),
              );
            }
            return;
          } else if (userResult != null && userResult.isServerError) {
            debugPrint('🚨 [TEST] 서버 오류 - 서버 오류 화면으로 이동');
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServerErrorScreen(),
                ),
              );
            }
            return;
          } else {
            debugPrint('❓ [TEST] 알 수 없는 오류 - 서버 오류 화면으로 이동');
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServerErrorScreen(),
                ),
              );
            }
            return;
          }
          break;

        case InitializationResult.dataRequiredOffline:
          // 데이터 부족 + 오프라인 상태 - 오프라인 경고 페이지로 이동
          debugPrint('[SplashScreen] 데이터 부족 + 오프라인 상태');
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OfflineWarningScreen()),
            );
          }
          break;

        case InitializationResult.failure:
          // 실패 시에도 기본 동작 수행
          debugPrint('[SplashScreen] 초기화 실패, 기본 동작 수행');
          ref.read(syncNotifierProvider.notifier).startSync();
          ref
              .read(mainNotifierProvider.notifier)
              .handleIntent(const CheckSavedGameIntent());
          break;
      }
    } catch (e) {
      debugPrint('[SplashScreen] 초기화 중 오류: $e');
      // 오류 발생 시에도 기본 동작 수행
      ref.read(syncNotifierProvider.notifier).startSync();
      ref
          .read(mainNotifierProvider.notifier)
          .handleIntent(const CheckSavedGameIntent());
    }
  }
}
