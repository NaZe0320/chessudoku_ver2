import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/notifiers/auth_notifier.dart';
import '../../../domain/states/auth_state.dart';
import '../../theme/color_palette.dart';
import '../../theme/app_text_styles.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 및 타이틀
              _buildHeader(),

              const Spacer(flex: 2),

              // 로그인 버튼들
              _buildLoginButtons(authNotifier, authState),

              // const Spacer(flex: 1),

              // // 익명 로그인 연결 옵션 (익명 사용자인 경우)
              // if (authNotifier.isAnonymousUser)
              //   _buildLinkAccountSection(authNotifier, authState),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 앱 아이콘/로고
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
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

        const SizedBox(height: 24),

        // 앱 이름
        Text(
          'ChesSudoku',
          style: AppTextStyles.headline1.copyWith(
            color: AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // 서브타이틀
        Text(
          '체스와 스도쿠의 만남',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(AuthNotifier authNotifier, AuthState authState) {
    return Column(
      children: [
        // Apple 로그인
        _buildLoginButton(
          icon: Icons.apple,
          text: 'Apple로 계속하기',
          backgroundColor: AppColors.onSurface,
          textColor: AppColors.textWhite,
          onPressed:
              authState.isLoading ? null : () => authNotifier.signInWithApple(),
        ),

        const SizedBox(height: 16),

        // Google 로그인
        _buildLoginButton(
          icon: Icons.g_mobiledata,
          text: 'Google로 계속하기',
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
          borderColor: AppColors.divider,
          onPressed: authState.isLoading
              ? null
              : () => authNotifier.signInWithGoogle(),
        ),

        const SizedBox(height: 16),

        // 익명 로그인
        _buildLoginButton(
          icon: Icons.person_outline,
          text: '게스트로 시작하기',
          backgroundColor: AppColors.primary,
          textColor: AppColors.textWhite,
          onPressed: authState.isLoading
              ? null
              : () => authNotifier.signInAnonymously(),
        ),

        if (authState.isLoading) ...[
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],

        if (authState.errorMessage != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authState.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: borderColor != null ? 0 : 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: AppTextStyles.buttonLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkAccountSection(
      AuthNotifier authNotifier, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            '계정 연결하기',
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '게스트 계정을 소셜 계정과 연결하면\n데이터를 안전하게 보관할 수 있어요',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLinkButton(
                  icon: Icons.apple,
                  text: 'Apple',
                  onPressed: authState.isLoading
                      ? null
                      : () => authNotifier.linkAnonymousWithApple(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLinkButton(
                  icon: Icons.g_mobiledata,
                  text: 'Google',
                  onPressed: authState.isLoading
                      ? null
                      : () => authNotifier.linkAnonymousWithGoogle(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.info,
          side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
