import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/core/network/network_service.dart';

/// 최초 실행 시 오프라인 상태일 때 표시하는 앱
class OfflineFirstLaunchApp extends StatefulWidget {
  const OfflineFirstLaunchApp({super.key});

  @override
  State<OfflineFirstLaunchApp> createState() => _OfflineFirstLaunchAppState();
}

class _OfflineFirstLaunchAppState extends State<OfflineFirstLaunchApp> {
  final NetworkService _networkService = NetworkService();
  bool _isCheckingConnection = false;

  @override
  void initState() {
    super.initState();
    // 네트워크 상태 변화 모니터링
    _networkService.connectionStatusStream.listen((isOnline) {
      if (isOnline && mounted) {
        _onNetworkRestored();
      }
    });
  }

  /// 네트워크 연결 복구 시 처리
  void _onNetworkRestored() {
    debugPrint('네트워크 연결 복구 감지');
    // 앱을 다시 시작하기 위해 시스템에 종료 요청
    SystemNavigator.pop();
  }

  /// 연결 확인 버튼 클릭
  Future<void> _checkConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    try {
      final isOnline = await _networkService.checkConnectivity();
      if (isOnline) {
        _onNetworkRestored();
      } else {
        // 여전히 오프라인 상태
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인터넷 연결을 확인해주세요.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('연결 확인 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingConnection = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChesSudoku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
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
                  // 앱 아이콘
                  Container(
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

                  const SizedBox(height: 32),

                  // 앱 이름
                  Text(
                    'ChesSudoku',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),

                  const SizedBox(height: 48),

                  // 오프라인 아이콘
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 64,
                    color: AppColors.textWhite.withValues(alpha: 0.8),
                  ),

                  const SizedBox(height: 24),

                  // 제목
                  Text(
                    '인터넷 연결이 필요합니다',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 설명
                  Text(
                    'ChesSudoku를 처음 사용하시는 경우,\n필수 데이터를 다운로드하기 위해\n인터넷 연결이 필요합니다.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // 연결 확인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _isCheckingConnection ? null : _checkConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: _isCheckingConnection
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : const Text(
                              '연결 확인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 안내 텍스트
                  Text(
                    'Wi-Fi 또는 모바일 데이터를 켜고\n다시 시도해주세요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // 버전 정보
                  Text(
                    'v0.1.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
