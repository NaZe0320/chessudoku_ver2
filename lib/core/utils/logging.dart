import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 앱 전역 로깅 설정
/// - debugPrint를 developer.log로 라우팅
/// - FlutterError를 developer.log로 라우팅
void setupLogging() {
  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      details.exceptionAsString(),
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );

    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  debugPrint = (String? message, {int? wrapWidth}) {
    if (message == null) return;
    developer.log(message, name: 'App');
  };
}
