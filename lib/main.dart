import 'package:chessudoku/core/utils/loading_manager.dart';
import 'package:chessudoku/data/services/api_service.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/device_service.dart';
import 'package:chessudoku/ui/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 캐시 서비스 초기화
  await CacheService().init();

  // 디바이스 서비스 초기화 (디바이스 ID 미리 생성)
  final deviceService = DeviceService();
  final deviceId = await deviceService.getDeviceId();
  debugPrint('Main: 앱 시작 - 디바이스 ID: $deviceId');

  // 데이터베이스 서비스 초기화 (첫 액세스만 해도 초기화됨)
  await DatabaseService().database;

  // API 서비스 초기화 (Dio 클라이언트 미리 생성)
  final apiService = ApiService();
  final _ = apiService.dio; // Dio 인스턴스 생성 트리거
  debugPrint('Main: API 서비스 초기화 완료');

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ChesSudoku',
      navigatorKey: LoadingManager.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
