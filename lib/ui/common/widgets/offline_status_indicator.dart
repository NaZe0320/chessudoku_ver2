import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chessudoku/core/network/connectivity_mixin.dart';
import 'package:chessudoku/core/offline/offline_manager.dart';

/// 오프라인 상태를 표시하는 위젯
class OfflineStatusIndicator extends HookWidget {
  const OfflineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = useNetworkStatus();
    final offlineManager = OfflineManager();
    final hasPendingSync = useState(false);
    final pendingSyncCount = useState(0);

    // 동기화 상태 모니터링
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        hasPendingSync.value = offlineManager.hasPendingSync;
        pendingSyncCount.value = offlineManager.pendingSyncCount;
      });

      return timer.cancel;
    }, []);

    if (isOnline) {
      // 온라인 상태
      if (hasPendingSync.value && pendingSyncCount.value > 0) {
        // 동기화 진행 중
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '동기화 중... ($pendingSyncCount)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    } else {
      // 오프라인 상태
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            const Text(
              '오프라인 모드',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasPendingSync.value) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pendingSyncCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
  }
}
