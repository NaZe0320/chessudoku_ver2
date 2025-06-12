import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 첫 프레임에서 동기화를 시작합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncNotifierProvider.notifier).startSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    // syncNotifierProvider를 listen하여 상태 변경 시 UI를 다시 빌드하고,
    // 동기화 완료 시 화면을 전환합니다.
    ref.listen(syncNotifierProvider, (previous, next) {
      if (next.isCompleted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    });

    // 동기화 상태를 화면에 표시합니다.
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              syncState.message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                value: syncState.progress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
