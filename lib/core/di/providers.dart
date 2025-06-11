import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/test_service.dart';
import '../../data/repositories/test_repository_impl.dart';
import '../../domain/repositories/test_repository.dart';

/// TestService Provider
final testServiceProvider = Provider<TestService>((ref) {
  return TestService();
});

/// TestRepository Provider
final testRepositoryProvider = Provider<TestRepository>((ref) {
  final testService = ref.watch(testServiceProvider);
  return TestRepositoryImpl(testService);
});
