import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/initialization/app_initializer.dart';
import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:chessudoku/presentation/screens/main/widgets/home_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OfflineWarningScreen extends HookConsumerWidget {
  const OfflineWarningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 영역: 오프라인 아이콘 (메인 테마와 동일한 스타일)
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        color: AppColors.warning,
                        size: 56,
                      ),
                    ),
                  ),

                  // 중앙 영역: 텍스트 정보
                  Column(
                    children: [
                      Text(
                        '인터넷 연결 필요',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '계정 생성 및 초기 데이터 다운로드를 위해\n네트워크 연결이 필요합니다.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // 하단 영역: 액션 버튼들 (HomeMenuButton 스타일 활용)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HomeMenuButton(
                        leadingIcon: Icons.refresh_rounded,
                        title: '다시 시도',
                        subtitle: '인터넷 연결을 다시 확인합니다',
                        showChevron: false,
                        height: 72,
                        enabled: !isLoading.value,
                        onTap: () => _handleRetry(context, ref, isLoading),
                      ),
                      
                      HomeMenuButton(
                        leadingIcon: Icons.settings_rounded,
                        title: '네트워크 설정',
                        subtitle: 'Wi-Fi 또는 모바일 데이터 설정',
                        showChevron: false,
                        height: 72,
                        enabled: !isLoading.value,
                        onTap: () => _handleNetworkSettings(context),
                      ),
                    ],
                  ),
                ],
              ),
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
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
          break;

        case InitializationResult.dataRequiredOffline:
          // 여전히 오프라인 상태 - 현재 페이지 유지
          _showRetryFailedMessage(context);
          break;

        case InitializationResult.failure:
          // 실패 - 에러 메시지 표시
          _showRetryFailedMessage(context);
          break;
      }
    } catch (e) {
      debugPrint('[OfflineWarningScreen] 재시도 중 오류: $e');
      _showRetryFailedMessage(context);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleNetworkSettings(BuildContext context) {
    // TODO: 네트워크 설정 화면으로 이동하는 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '설정 > Wi-Fi에서 네트워크 연결을 확인해주세요',
          style: TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showRetryFailedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '네트워크 연결을 확인해주세요',
          style: TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
