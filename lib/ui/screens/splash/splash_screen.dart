import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/intents/main_intent.dart';
import 'package:chessudoku/ui/screens/main/main_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/screens/tutorial/tutorial_screen.dart';
import 'package:chessudoku/core/constants/splash_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoController = useAnimationController(
      duration: SplashConstants.logoAnimationDuration,
    );

    final progressController = useAnimationController(
      duration: SplashConstants.progressAnimationDuration,
    );

    // 애니메이션 시작
    useEffect(() {
      logoController.forward();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        progressController.forward();
        await _performInitialization(ref);
      });

      return null;
    }, []);

    final translate = ref.watch(translationProvider);
    final syncState = ref.watch(syncNotifierProvider);

    // 동기화 완료 시 화면 전환
    ref.listen(syncNotifierProvider, (previous, next) async {
      if (next.isCompleted) {
        await _handleSyncCompletion(ref, context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 및 앱 정보 섹션
              _buildLogoSection(logoController, translate),

              const Spacer(flex: 1),

              // 진행 상황 섹션
              _buildProgressSection(progressController, syncState, translate),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  /// 로고 및 앱 정보 섹션
  Widget _buildLogoSection(AnimationController logoController,
      String Function(String, String) translate) {
    return TweenAnimationBuilder<double>(
      duration: SplashConstants.logoAnimationDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Column(
          children: [
            // 로고 아이콘
            Transform.scale(
              scale: value.clamp(0.0, 1.0),
              child: Container(
                width: SplashConstants.logoSize,
                height: SplashConstants.logoSize,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(SplashConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: SplashConstants.shadowAlpha),
                      blurRadius: SplashConstants.shadowBlur,
                      offset: const Offset(0, SplashConstants.shadowOffset),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_view,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: SplashConstants.logoSpacing),

            // 앱 이름
            Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Text(
                translate('app_name', 'ChesSudoku'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ),

            const SizedBox(height: SplashConstants.descriptionSpacing),

            // 앱 설명
            Opacity(
              opacity: (value * 0.8).clamp(0.0, 1.0),
              child: Text(
                translate('app_description', '체스와 스도쿠의 만남'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textWhite
                          .withValues(alpha: SplashConstants.descriptionAlpha),
                      letterSpacing: 0.5,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 진행 상황 섹션
  Widget _buildProgressSection(
    AnimationController progressController,
    dynamic syncState,
    String Function(String, String) translate,
  ) {
    return TweenAnimationBuilder<double>(
      duration: SplashConstants.progressAnimationDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Column(
            children: [
              // 로딩 인디케이터
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  backgroundColor: AppColors.textWhite.withValues(
                      alpha: SplashConstants.progressBackgroundAlpha),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: SplashConstants.progressSpacing),
              // 상태 텍스트
              _buildStatusText(syncState, translate),

              const SizedBox(height: SplashConstants.progressSpacing),

              // 프로그레스 바
              _buildProgressBar(syncState),

              const SizedBox(height: SplashConstants.descriptionSpacing),

              // 진행률 퍼센트
              Text(
                '${(syncState.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textWhite
                          .withValues(alpha: SplashConstants.progressTextAlpha),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 상태 텍스트 위젯
  Widget _buildStatusText(
      dynamic syncState, String Function(String, String) translate) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textWhite.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.textWhite
                .withValues(alpha: SplashConstants.progressBorderAlpha),
            width: 1,
          ),
        ),
        child: Text(
          translate(
            syncState.message.toLowerCase().replaceAll(' ', '_'),
            syncState.message,
          ),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 프로그레스 바 위젯
  Widget _buildProgressBar(dynamic syncState) {
    return Builder(
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width *
            SplashConstants.progressBarWidthRatio,
        height: SplashConstants.progressBarHeight,
        decoration: BoxDecoration(
          color: AppColors.textWhite
              .withValues(alpha: SplashConstants.progressBackgroundAlpha),
          borderRadius: BorderRadius.circular(3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: syncState.progress,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      ),
    );
  }

  /// 통합 초기화 수행
  Future<void> _performInitialization(WidgetRef ref) async {
    try {
      debugPrint('[SplashScreen] 통합 초기화 시작');

      final gameSaveRepository = ref.read(gameSaveRepositoryProvider);
      final userProfileRepository = ref.read(userProfileRepositoryProvider);
      final appInitializer = ref.read(appInitializerProvider);

      final result = await appInitializer.initialize(
        gameSaveRepository: gameSaveRepository,
        userProfileRepository: userProfileRepository,
      );

      debugPrint('[SplashScreen] 초기화 결과: $result');

      // 모든 케이스에서 동일한 후속 작업 수행
      _startSyncAndCheckSavedGame(ref);
    } catch (e) {
      debugPrint('[SplashScreen] 초기화 중 오류: $e');
      _startSyncAndCheckSavedGame(ref);
    }
  }

  /// 동기화 시작 및 저장된 게임 확인
  void _startSyncAndCheckSavedGame(WidgetRef ref) {
    ref.read(syncNotifierProvider.notifier).startSync();
    ref
        .read(mainNotifierProvider.notifier)
        .handleIntent(const CheckSavedGameIntent());
  }

  /// 동기화 완료 처리
  Future<void> _handleSyncCompletion(
      WidgetRef ref, BuildContext context) async {
    try {
      await ref
          .read(languagePackNotifierProvider.notifier)
          .restoreLanguageSettings();
      debugPrint('[SplashScreen] 언어 설정 복원 완료');
    } catch (e) {
      debugPrint('[SplashScreen] 언어 설정 복원 실패: $e');
    }

    // 튜토리얼 완료 여부에 따른 화면 전환
    final cache = ref.read(cacheServiceProvider);
    final completed = cache.getBool('tutorial_completed') ?? false;

    final targetScreen =
        completed ? const MainScreen() : const TutorialScreen();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => targetScreen),
      (route) => false,
    );
  }
}
