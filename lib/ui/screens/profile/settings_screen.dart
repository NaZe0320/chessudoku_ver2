import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/screens/profile/language_settings_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final translate = ref.watch(translationProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            title: Text(
              translate('settings', '설정'),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            centerTitle: true,
            elevation: 0,
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 앱 정보 헤더
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // 앱 아이콘
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.grid_view,
                            size: 40,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 앱 이름
                        Text(
                          translate('app_name', 'ChesSudoku'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 앱 설명
                        Text(
                          translate('app_description', '체스와 스도쿠의 만남'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 일반 설정 섹션
                  Text(
                    translate('general_settings', '일반 설정'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: AppColors.surface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.notifications_outlined,
                          title: translate('notification_settings', '알림 설정'),
                          onTap: () {
                            // 알림 설정 페이지로 이동
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.language_outlined,
                          title: translate('language_settings', '언어 설정'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LanguageSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.storage_outlined,
                          title: translate('storage_management', '저장소 관리'),
                          onTap: () {
                            // 저장소 관리 페이지로 이동
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 정보 섹션
                  Text(
                    translate('information', '정보'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: AppColors.surface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.help_outline,
                          title: translate('help', '도움말'),
                          onTap: () {
                            // 도움말 페이지로 이동
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.info_outline,
                          title: translate('app_info', '앱 정보'),
                          onTap: () {
                            // 앱 정보 페이지로 이동
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                        ),
                        _buildSettingTile(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: translate('privacy_policy', '개인정보 처리방침'),
                          onTap: () {
                            // 개인정보 처리방침 페이지로 이동
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32), // 하단 여백
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
    );
  }
}
