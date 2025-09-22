import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/initialization/app_initializer.dart';
import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OfflineWarningScreen extends HookConsumerWidget {
  const OfflineWarningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    final translate = ref.watch(translationProvider);

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // 경고 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppColors.warning,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 60,
                    color: AppColors.warning,
                  ),
                ),

                const SizedBox(height: 32),

                // 제목
                Text(
                  '오프라인 상태',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // 설명
                Text(
                  '인터넷 연결이 필요합니다.\n\n계정 생성 및 초기 데이터 다운로드를 위해 네트워크 연결이 필요합니다.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // 재시도 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading.value
                        ? null
                        : () => _handleRetry(context, ref, isLoading),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textWhite,
                      elevation: 8,
                      shadowColor: AppColors.accent.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textWhite),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '다시 시도',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // 도움말 텍스트
                Text(
                  'Wi-Fi 또는 모바일 데이터를 확인해주세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRetry(BuildContext context, WidgetRef ref,
      ValueNotifier<bool> isLoading) async {
    try {
      isLoading.value = true;

      // Repository 인스턴스 가져오기
      final gameSaveRepository = ref.read(gameSaveRepositoryProvider);
      // userProfileRepository 제거됨

      // AppInitializer를 통한 재초기화
      final appInitializer = ref.read(appInitializerProvider);
      final result = await appInitializer.initialize(
        gameSaveRepository: gameSaveRepository,
      );

      debugPrint('[OfflineWarningScreen] 재시도 결과: $result');

      switch (result) {
        case InitializationResult.success:
          // 성공 시 스플래시로 돌아가서 정상 진행
          Navigator.of(context).pushReplacementNamed('/splash');
          break;

        case InitializationResult.dataRequiredOffline:
          // 여전히 오프라인 상태 - 현재 페이지 유지
          _showRetryFailedMessage(context, ref);
          break;

        case InitializationResult.failure:
          // 실패 - 에러 메시지 표시
          _showRetryFailedMessage(context, ref);
          break;
      }
    } catch (e) {
      debugPrint('[OfflineWarningScreen] 재시도 중 오류: $e');
      _showRetryFailedMessage(context, ref);
    } finally {
      isLoading.value = false;
    }
  }

  void _showRetryFailedMessage(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '네트워크 연결을 확인해주세요',
          style: TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
