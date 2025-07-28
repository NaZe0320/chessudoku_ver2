import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/screens/splash/splash_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  // 디바이스 서비스 초기화
  final deviceId = await container.read(deviceServiceProvider).getDeviceId();
  debugPrint('Main: 앱 시작 - 디바이스 ID: $deviceId');

  // 데이터베이스 서비스 초기화
  await container.read(databaseServiceProvider).database;
  debugPrint('Main: 데이터베이스 서비스 초기화 완료');

  // API 서비스 초기화
  container.read(apiServiceProvider).dio;
  debugPrint('Main: API 서비스 초기화 완료');

  // Firestore 서비스 초기화
  container.read(firestoreServiceProvider).firestore;
  debugPrint('Main: Firestore 서비스 초기화 완료');

  // 데이터 버전 체크 및 동기화 -> SplashScreen으로 로직 이동
  // debugPrint('Main: 데이터 버전 동기화 시작...');
  // await container.read(versionRepositoryProvider).checkVersionAndSync();
  // debugPrint('Main: 데이터 버전 동기화 완료.');
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
