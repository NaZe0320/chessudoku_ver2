/// 언어팩 정보를 담는 모델 클래스
class LanguagePack {
  final String id;
  final String name;
  final String nativeName;
  final String languageCode;
  final String countryCode;
  final bool isDownloaded;
  final bool isDefault;
  final String? version;
  final DateTime? lastUpdated;
  final int downloadSize;
  final Map<String, String> translations;

  const LanguagePack({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.languageCode,
    required this.countryCode,
    this.isDownloaded = false,
    this.isDefault = false,
    this.version,
    this.lastUpdated,
    required this.downloadSize,
    this.translations = const {},
  });

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

  /// 언어팩 복사 (상태 변경용)
  LanguagePack copyWith({
    String? id,
    String? name,
    String? nativeName,
    String? languageCode,
    String? countryCode,
    bool? isDownloaded,
    bool? isDefault,
    String? version,
    DateTime? lastUpdated,
    int? downloadSize,
    Map<String, String>? translations,
  }) {
    return LanguagePack(
      id: id ?? this.id,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isDefault: isDefault ?? this.isDefault,
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      downloadSize: downloadSize ?? this.downloadSize,
      translations: translations ?? this.translations,
    );
  }
}
