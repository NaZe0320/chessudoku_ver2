import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 설정 관리 클래스
class ApiConfig {
  // 환경 변수에서 URL을 가져오고, 없으면 기본값 사용
  static String get devUrl =>
      dotenv.env['DEV_API_URL'] ?? 'http://localhost:3000/api';
  static String get prodUrl =>
      dotenv.env['PROD_API_URL'] ?? 'https://api.chessudoku.com/api';

  // 환경 변수에서 타임아웃을 가져오고, 없으면 기본값 사용
  static Duration get timeout {
    final timeoutSeconds =
        int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;
    return Duration(seconds: timeoutSeconds);
  }

  static String get baseUrl => kDebugMode ? devUrl : prodUrl;

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
