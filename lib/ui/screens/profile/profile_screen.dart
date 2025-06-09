import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/notifiers/auth_notifier.dart';
import '../../../domain/intents/auth_intent.dart';

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
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
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
                  // 프로필 헤더
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
                        // 프로필 아이콘
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 사용자 이름
                        Text(
                          authState.user?.displayName ?? '사용자',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // 이메일
                        Text(
                          authState.user?.email ?? '',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 계정 정보 섹션
                  Text(
                    '계정 정보',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // 정보 리스트
                  Card(
                    child: Column(
                      children: [
                        _buildInfoTile(
                          context,
                          icon: Icons.email_outlined,
                          title: '이메일',
                          subtitle: authState.user?.email ?? '정보 없음',
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          context,
                          icon: Icons.person_outline,
                          title: '사용자 ID',
                          subtitle: authState.user?.id ?? '정보 없음',
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          context,
                          icon: Icons.offline_bolt_outlined,
                          title: '오프라인 인증',
                          subtitle:
                              authState.user?.isOfflineAuthenticated == true
                                  ? '활성화됨'
                                  : '비활성화됨',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 추가 설정 섹션
                  Text(
                    '설정',
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
                          title: '알림 설정',
                          onTap: () {
                            // 알림 설정 페이지로 이동
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          context,
                          icon: Icons.language_outlined,
                          title: '언어 설정',
                          onTap: () {
                            // 언어 설정 페이지로 이동
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          context,
                          icon: Icons.help_outline,
                          title: '도움말',
                          onTap: () {
                            // 도움말 페이지로 이동
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingTile(
                          context,
                          icon: Icons.info_outline,
                          title: '앱 정보',
                          onTap: () {
                            // 앱 정보 페이지로 이동
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 로그아웃 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context, ref);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('로그아웃'),
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

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말로 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).handleIntent(
                      const SignOutIntent(),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }
}
