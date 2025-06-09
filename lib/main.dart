import 'package:chessudoku/core/utils/loading_manager.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/ui/screens/main/main_screen.dart';
import 'package:chessudoku/ui/screens/login/login_screen.dart';
import 'package:chessudoku/domain/notifiers/auth_notifier.dart';
import 'package:chessudoku/domain/states/auth_state.dart';
import 'package:chessudoku/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 캐시 서비스 초기화
  await CacheService().init();

  // 데이터베이스 서비스 초기화 (첫 액세스만 해도 초기화됨)
  await DatabaseService().database;

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return switch (authState.status) {
      AuthStatus.initial => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      AuthStatus.loading => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      AuthStatus.authenticated => const MainScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}
