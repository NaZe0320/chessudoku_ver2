import 'package:chessudoku/data/models/language_pack.dart';

class LanguagePackState {
  final List<LanguagePack> languagePacks;
  final LanguagePack? currentLanguagePack;
  final bool isLoading;
  final String? errorMessage;

  const LanguagePackState({
    this.languagePacks = const [],
    this.currentLanguagePack,
    this.isLoading = false,
    this.errorMessage,
  });

  LanguagePackState copyWith({
    List<LanguagePack>? languagePacks,
    LanguagePack? currentLanguagePack,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LanguagePackState(
      languagePacks: languagePacks ?? this.languagePacks,
      currentLanguagePack: currentLanguagePack ?? this.currentLanguagePack,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

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
