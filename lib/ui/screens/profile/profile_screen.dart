import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/screens/profile/language_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translate = ref.watch(translationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('settings')),
        centerTitle: true,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
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
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // 앱 아이콘
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.grid_view,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 앱 이름
                        Text(
                          translate('app_name'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // 앱 설명
                        Text(
                          translate('app_description', '체스와 스도쿠의 만남'),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 게임 설정 섹션
                  Text(
                    translate('game_settings', '게임 설정'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context,
                          icon: Icons.volume_up_outlined,
                          title: translate('sound_effects', '사운드 효과'),
                          onTap: () {
                            // 사운드 설정 페이지로 이동
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          context,
                          icon: Icons.vibration_outlined,
                          title: translate('vibration', '진동'),
                          onTap: () {
                            // 진동 설정 페이지로 이동
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          context,
                          icon: Icons.palette_outlined,
                          title: translate('theme_settings', '테마 설정'),
                          onTap: () {
                            // 테마 설정 페이지로 이동
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 일반 설정 섹션
                  Text(
                    translate('general_settings', '일반 설정'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Card(
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
                        const Divider(height: 1),
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
                        const Divider(height: 1),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Card(
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
                        const Divider(height: 1),
                        _buildSettingTile(
                          context,
                          icon: Icons.info_outline,
                          title: translate('app_info', '앱 정보'),
                          onTap: () {
                            // 앱 정보 페이지로 이동
                          },
                        ),
                        const Divider(height: 1),
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
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
    );
  }
}
