import 'package:chessudoku/presentation/screens/splash/splash_screen.dart';
import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:chessudoku/core/initialization/app_initializer.dart'; // 사용되지 않음
import 'package:chessudoku/core/utils/logging.dart';

// 전역 서비스 인스턴스들 (앱 시작 전 초기화)
DatabaseService? _globalDatabaseService;

/// 앱 재시작을 위한 전역 함수
void restartApp() {
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 로깅 초기화
  setupLogging();

  // 상태바 스타일 설정 (앱 전체에 적용)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary, // 상태바 배경색
      statusBarIconBrightness: Brightness.light, // 아이콘 밝기 (어두운 배경에 밝은 아이콘)
      statusBarBrightness: Brightness.dark, // iOS용 설정
    ),
  );

  // --- 전역 서비스들 초기화 ---
  // Provider 시스템과 별개로 전역 서비스들을 먼저 초기화
  await _initializeGlobalServices();

  runApp(
    const ProviderScope(
      // 자식 위젯에서 프로바이더를 사용할 수 있도록 ProviderScope로 감싸기
      child: MainApp(),
    ),
  );
}

/// 전역 서비스들을 초기화하는 함수 (Provider 시스템 이전에 실행)
Future<void> _initializeGlobalServices() async {
  // 캐시 서비스 전역 초기화 (Singleton)
  await CacheService.initializeGlobal();

  // 데이터베이스 서비스 초기화
  _globalDatabaseService = DatabaseService();
  await _globalDatabaseService!.database; // 데이터베이스 연결 초기화
  debugPrint('Main: DatabaseService 전역 초기화 완료');
}

/// 전역 DatabaseService 인스턴스 반환 (Provider에서 사용)
DatabaseService getGlobalDatabaseService() {
  if (_globalDatabaseService == null) {
    throw StateError('전역 DatabaseService가 초기화되지 않았습니다. main()에서 _initializeGlobalServices()를 먼저 호출하세요.');
  }
  return _globalDatabaseService!;
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ChesSudoku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // 앱 전체에서 시스템 글자 크기 설정 무시
          ),
          child: child!,
        );
      },
    );
  }
}
