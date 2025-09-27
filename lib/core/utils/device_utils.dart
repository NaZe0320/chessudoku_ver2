import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// 디바이스 관련 유틸리티 함수들
class DeviceUtils {
  static const String _fallbackCacheKey = 'device_id';

  /// 디바이스 고유 ID 획득
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidId() ?? await _getFallbackId();
      } else if (Platform.isIOS) {
        return await _getIOSId() ?? await _getFallbackId();
      } else {
        return await _getFallbackId();
      }
    } catch (e) {
      if (kDebugMode) {
        print('DeviceUtils: 디바이스 ID 획득 중 오류: $e');
      }
      return await _getFallbackId();
    }
  }

  /// Android 디바이스 ID 획득
  static Future<String?> _getAndroidId() async {
    try {
      final androidId = await const AndroidId().getId();
      if (androidId != null && androidId.isNotEmpty && androidId != 'unknown') {
        return androidId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('DeviceUtils: Android ID 획득 실패: $e');
      }
    }
    return null;
  }

  /// iOS 디바이스 ID 획득
  static Future<String?> _getIOSId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      final vendorId = iosInfo.identifierForVendor;

      if (vendorId != null && vendorId.isNotEmpty) {
        return vendorId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('DeviceUtils: iOS ID 획득 실패: $e');
      }
    }
    return null;
  }

  /// Fallback UUID 디바이스 ID
  static Future<String> _getFallbackId() async {
    // 캐시에서 기존 ID 확인
    final cachedId = CacheService.getInstance().getString(_fallbackCacheKey);
    if (cachedId != null && cachedId.isNotEmpty) {
      return cachedId;
    }

    // 새로운 UUID 생성 및 캐시
    final newId = const Uuid().v4();
    await CacheService.getInstance().setString(_fallbackCacheKey, newId);
    return newId;
  }

  /// 디바이스 ID 캐시 초기화 (테스트용)
  @visibleForTesting
  static Future<void> resetDeviceId() async {
    await CacheService.getInstance().remove(_fallbackCacheKey);
  }
}
