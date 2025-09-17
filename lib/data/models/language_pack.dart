import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_pack.freezed.dart';
part 'language_pack.g.dart';

/// 언어팩 정보를 담는 모델 클래스
@freezed
class LanguagePack with _$LanguagePack {
  const factory LanguagePack({
    required String id,
    required String name,
    required String nativeName,
    required String languageCode,
    required String countryCode,
    @Default(false) bool isDownloaded,
    @Default(false) bool isDefault,
    String? version,
    DateTime? lastUpdated,
    required int downloadSize,
    @Default({}) Map<String, String> translations,
  }) = _LanguagePack;

  const LanguagePack._();

  /// 지역 설정 (Locale) 반환
  String get locale => '${languageCode}_$countryCode';

  /// 다운로드 크기를 사람이 읽기 쉬운 형태로 반환
  String get formattedSize {
    if (downloadSize < 1024) {
      return '${downloadSize}B';
    } else if (downloadSize < 1024 * 1024) {
      return '${(downloadSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(downloadSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// JSON 직렬화를 위한 팩토리 메서드
  factory LanguagePack.fromJson(Map<String, dynamic> json) =>
      _$LanguagePackFromJson(json);

  /// Map으로부터 LanguagePack 생성 (기존 호환성 유지)
  factory LanguagePack.fromMap(Map<String, dynamic> map) {
    Map<String, String> translations = {};
    if (map['translations'] != null &&
        (map['translations'] as String).isNotEmpty) {
      final translationPairs = (map['translations'] as String).split('||');
      for (final pair in translationPairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          translations[parts[0]] = parts[1];
        }
      }
    }

    return LanguagePack(
      id: map['id'] as String,
      name: map['name'] as String,
      nativeName: map['nativeName'] as String,
      languageCode: map['languageCode'] as String,
      countryCode: map['countryCode'] as String,
      isDownloaded: (map['isDownloaded'] as int) == 1,
      isDefault: (map['isDefault'] as int) == 1,
      version: map['version'] as String?,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] as int)
          : null,
      downloadSize: map['downloadSize'] as int,
      translations: translations,
    );
  }

  /// Map으로 변환 (기존 호환성 유지)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nativeName': nativeName,
      'languageCode': languageCode,
      'countryCode': countryCode,
      'isDownloaded': isDownloaded ? 1 : 0,
      'isDefault': isDefault ? 1 : 0,
      'version': version,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'downloadSize': downloadSize,
      'translations': translations.isNotEmpty
          ? translations.entries.map((e) => '${e.key}:${e.value}').join('||')
          : '',
    };
  }
}
