import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/core/network/network_service.dart';
import 'package:chessudoku/core/initialization/app_initializer.dart';
import 'package:chessudoku/main.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/repositories/user_profile_repository.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/device_service.dart';
import 'package:chessudoku/data/repositories/game_save_repository_impl.dart';
import 'package:chessudoku/data/repositories/user_profile_repository_impl.dart';
import 'package:chessudoku/core/sync/sync_manager.dart';

/// 최초 실행 시 오프라인 상태일 때 표시하는 앱
class OfflineFirstLaunchApp extends StatefulWidget {
  const OfflineFirstLaunchApp({super.key});

  @override
  State<OfflineFirstLaunchApp> createState() => _OfflineFirstLaunchAppState();
}

class _OfflineFirstLaunchAppState extends State<OfflineFirstLaunchApp> {
  final NetworkService _networkService = NetworkService();
  final AppInitializer _appInitializer = AppInitializer();
  bool _isCheckingConnection = false;
  bool _isInitializing = false;

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
  Future<void> _onNetworkRestored() async {
    debugPrint('네트워크 연결 복구 감지');

    if (_isInitializing) return; // 중복 실행 방지

    setState(() {
      _isInitializing = true;
    });

    try {
      // Repository 인스턴스 생성 (Provider 없이 직접 생성)
      final gameSaveRepository = _createGameSaveRepository();
      final userProfileRepository = _createUserProfileRepository();

      // 앱 재초기화 실행 (네트워크 복구 후)
      final result = await _appInitializer.reinitialize(
        gameSaveRepository: gameSaveRepository,
        userProfileRepository: userProfileRepository,
      );

      if (result == InitializationResult.success) {
        debugPrint('재초기화 성공 - 정상 앱으로 전환');
        // 재초기화 성공 시 앱을 완전히 재시작
        if (mounted) {
          _restartAppCompletely();
        }
      } else {
        debugPrint('재초기화 실패: $result');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('재초기화에 실패했습니다: $result'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('재초기화 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  /// GameSaveRepository 인스턴스 생성
  GameSaveRepository _createGameSaveRepository() {
    // Provider 없이 직접 생성
    final cacheService = CacheService();
    return GameSaveRepositoryImpl(cacheService);
  }

  /// UserProfileRepository 인스턴스 생성
  UserProfileRepository _createUserProfileRepository() {
    // Provider 없이 직접 생성
    final databaseService = DatabaseService();
    final deviceService = DeviceService();
    final networkService = NetworkService();
    final syncManager = SyncManager();

    return UserProfileRepositoryImpl(
      databaseService,
      deviceService,
      networkService,
      syncManager,
    );
  }

  /// 앱을 완전히 재시작
  void _restartAppCompletely() {
    // 전역 함수를 사용하여 앱을 완전히 재시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restartApp();
    });
  }

  /// 연결 확인 버튼 클릭
  Future<void> _checkConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    try {
      final isOnline = await _networkService.checkConnectivity();
      if (isOnline) {
        await _onNetworkRestored();
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
      home: ScaffoldMessenger(
        child: Scaffold(
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
                  children: [
                    // 상단 여백
                    const SizedBox(height: 40),

                    // 앱 아이콘과 이름 섹션
                    Column(
                      children: [
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
                        const SizedBox(height: 24),
                        Text(
                          'ChesSudoku',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),

                    // 중앙 여백
                    const Spacer(),

                    // 오프라인 상태 섹션
                    Column(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 80,
                          color: AppColors.textWhite.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '인터넷 연결이 필요합니다',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ChesSudoku를 처음 사용하시는 경우,\n필수 데이터를 다운로드하기 위해\n인터넷 연결이 필요합니다.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color:
                                    AppColors.textWhite.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // 하단 여백
                    const Spacer(),

                    // 액션 버튼 섹션
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                (_isCheckingConnection || _isInitializing)
                                    ? null
                                    : _checkConnection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                            child: (_isCheckingConnection || _isInitializing)
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
                        Text(
                          'Wi-Fi 또는 모바일 데이터를 켜고\n다시 시도해주세요.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    AppColors.textWhite.withValues(alpha: 0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // 하단 여백
                    const SizedBox(height: 40),

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
      ),
    );
  }
}
