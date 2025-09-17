import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/initialization/app_initializer.dart';

// ==================== Infrastructure ====================

/// AppInitializer Provider - 앱 초기화
final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer();
});
