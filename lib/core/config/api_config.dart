import 'package:flutter/foundation.dart';

/// API 설정 관리 클래스
class ApiConfig {
  static const String devUrl = 'http://localhost:3000/api';
  static const String prodUrl = 'https://api.chessudoku.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static String get baseUrl => kDebugMode ? devUrl : prodUrl;

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
