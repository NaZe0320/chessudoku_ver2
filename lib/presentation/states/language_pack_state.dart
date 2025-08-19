import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/data/models/language_pack.dart';

part 'language_pack_state.freezed.dart';

@freezed
class LanguagePackState with _$LanguagePackState {
  const factory LanguagePackState({
    @Default([]) List<LanguagePack> languagePacks,
    LanguagePack? currentLanguagePack,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _LanguagePackState;

  const LanguagePackState._();

  /// 현재 언어의 번역 가져오기
  String translate(String key, [String? defaultValue]) {
    if (currentLanguagePack == null) {
      return defaultValue ?? key;
    }
    return currentLanguagePack!.translations[key] ?? defaultValue ?? key;
  }

  /// 다운로드된 언어팩 목록
  List<LanguagePack> get downloadedPacks =>
      languagePacks.where((pack) => pack.isDownloaded).toList();

  /// 사용 가능한 언어팩 목록 (다운로드되지 않은 것들)
  List<LanguagePack> get availablePacks =>
      languagePacks.where((pack) => !pack.isDownloaded).toList();

  /// 현재 언어 코드
  String get currentLanguageCode => currentLanguagePack?.languageCode ?? 'ko';
}
