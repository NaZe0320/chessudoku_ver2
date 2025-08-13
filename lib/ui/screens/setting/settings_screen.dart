import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/screens/setting/language_settings_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/screens/setting/widgets/game_settings_card.dart';
import 'package:chessudoku/ui/screens/setting/widgets/language_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final translate = ref.watch(translationProvider);
    final languageState = ref.watch(languagePackNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          translate('settings', '설정'),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textWhite,
        centerTitle: true,
        elevation: 0,
      ),
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
            controller: scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 헤더 (계정 & 프로필 영역)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.secondary,
                        child: Icon(
                          Icons.person,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate('account_profile', '계정 & 프로필'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              translate('manage_profile', '프로필 설정 및 계정 관리'),
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    AppColors.textWhite.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // 프로필 상세 페이지로 이동
                        },
                        icon: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textWhite,
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 계정 & 프로필 섹션 제거 (상단 헤더가 동일 역할 수행)
                const SizedBox(height: 16),

                // 2. 게임 설정 (토글)
                Text(
                  translate('game_settings', '게임 설정'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 12),
                GameSettingsCard(translate: translate),

                const SizedBox(height: 24),

                // 3. 언어 설정
                Text(
                  translate('language_settings', '언어 설정'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: LanguageTile(
                    title: translate('language', '언어'),
                    subtitle: languageState.currentLanguagePack?.nativeName ??
                        translate('system_default', '시스템 기본'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 4. 프리미엄 & 구독
                Text(
                  translate('premium_subscriptions', '프리미엄 & 구독'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        context,
                        icon: Icons.workspace_premium_outlined,
                        title: translate(
                            'premium_and_subscription', '프리미엄/구독 관리 및 혜택'),
                        onTap: () {
                          // 구독 관리
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. 도움말 & 학습
                Text(
                  translate('help_learning', '도움말 & 학습'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        context,
                        icon: Icons.school_outlined,
                        title: translate('tutorial', '튜토리얼'),
                        onTap: () {
                          // 튜토리얼
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildSettingTile(
                        context,
                        icon: Icons.menu_book_outlined,
                        title: translate('game_guide', '게임 가이드'),
                        onTap: () {
                          // 게임 가이드
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 6. 앱 정보 & 정책
                Text(
                  translate('app_info_policy', '앱 정보 & 정책'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        context,
                        icon: Icons.info_outline,
                        title: translate('app_info', '앱 정보'),
                        onTap: () {
                          // 앱 정보
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildSettingTile(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: translate('privacy_policy', '개인정보 처리방침'),
                        onTap: () {
                          // 개인정보 처리방침
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildSettingTile(
                        context,
                        icon: Icons.article_outlined,
                        title: translate('terms_of_service', '이용약관'),
                        onTap: () {
                          // 이용약관
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 하단 위험 구역: 계정 삭제 링크 (붉은 글자)
                Center(
                  child: InkWell(
                    onTap: () {
                      // 계정 삭제 플로우 시작
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        translate('delete_account', '계정 삭제'),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textWhite),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textWhite.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: AppColors.textWhite.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// widgets moved to profile/widgets/
