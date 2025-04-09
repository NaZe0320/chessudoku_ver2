import 'package:chessudoku/core/routes/app_routes.dart';
import 'package:chessudoku/data/models/user.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chessudoku/core/di/auth_providers.dart';
import 'package:chessudoku/ui/common/widgets/auth_state_builder.dart';
import 'package:chessudoku/ui/auth/login_screen.dart';
import 'package:chessudoku/ui/screens/main/main_screen.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 캐시 서비스 초기화
  await CacheService().init();

  // 데이터베이스 서비스 초기화 (첫 액세스만 해도 초기화됨)
  await DatabaseService().database;

  // Firebase 초기화
  await Firebase.initializeApp();

  // SharedPreferences 초기화
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Sudoku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthStateBuilder(
        authenticatedBuilder: MainScreen.new,
        unauthenticatedBuilder: LoginScreen.new,
      ),
    );
  }
}
