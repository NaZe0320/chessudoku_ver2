import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/screens/splash/splash_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chessudoku/core/initialization/app_initializer.dart';
import 'package:chessudoku/core/utils/logging.dart';

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

  // --- Dependency Injection Container 생성 ---
  // 앱 실행 전 초기화가 필요한 프로바이더들을 위해 임시 컨테이너 생성
  final container = ProviderContainer();

  // 앱 실행에 필수적인 서비스들 초기화
  await _initializeServices(container);

  // 앱 초기화 시스템 실행
  final appInitializer = AppInitializer();
  final gameSaveRepository = container.read(gameSaveRepositoryProvider);
  final userProfileRepository = container.read(userProfileRepositoryProvider);

  await appInitializer.initialize(
    gameSaveRepository: gameSaveRepository,
    userProfileRepository: userProfileRepository,
  );

  // 사용이 끝난 임시 컨테이너는 폐기
  container.dispose();

  runApp(
    const ProviderScope(
      // 자식 위젯에서 프로바이더를 사용할 수 있도록 ProviderScope로 감싸기
      child: MainApp(),
    ),
  );
}

/// 앱 실행에 필수적인 서비스들을 초기화하는 함수
Future<void> _initializeServices(ProviderContainer container) async {
  // 캐시 서비스 초기화
  await container.read(cacheServiceProvider).init();

  // 데이터베이스 서비스 초기화
  await container.read(databaseServiceProvider).database;
  debugPrint('Main: 데이터베이스 서비스 초기화 완료');
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
