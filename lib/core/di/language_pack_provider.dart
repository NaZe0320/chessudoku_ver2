import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/data/repositories/language_repository_impl.dart';
import 'package:chessudoku/domain/notifiers/language_pack_notifier.dart';
import 'package:chessudoku/domain/repositories/language_repository.dart';
import 'package:chessudoku/domain/states/language_pack_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 언어 Repository Provider
final languageRepositoryProvider = Provider<LanguageRepository>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  return LanguageRepositoryImpl(databaseService);
});

/// 언어팩 Notifier Provider
final languagePackNotifierProvider =
    StateNotifierProvider<LanguagePackNotifier, LanguagePackState>((ref) {
  final languageRepository = ref.read(languageRepositoryProvider);
  return LanguagePackNotifier(languageRepository);
});

/// 번역 헬퍼 Provider
final translationProvider = Provider<String Function(String, [String?])>((ref) {
  final languageState = ref.watch(languagePackNotifierProvider);
  return (String key, [String? defaultValue]) {
    return languageState.translate(key, defaultValue);
  };
});
