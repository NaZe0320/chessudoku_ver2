import 'package:chessudoku/core/routes/app_routes.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 캐시 서비스 초기화
  await CacheService().init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoutes.main,
      routes: AppRoutes.routes,
    );
  }
}
