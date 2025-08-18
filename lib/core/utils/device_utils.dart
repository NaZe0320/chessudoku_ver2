import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 디바이스 관련 유틸리티 함수들
class DeviceUtils {
  /// 디바이스 고유 ID 획득
  ///
  /// Android: Android ID 사용
  /// iOS: identifierForVendor 사용
  /// 기타: UUID fallback
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        return await getAndroidDeviceId();
      } else if (Platform.isIOS) {
        return await getIOSDeviceId();
      } else {
        // 다른 플랫폼의 경우 UUID fallback
        return await getFallbackDeviceId();
      }
    } catch (e) {
      debugPrint('DeviceUtils: 디바이스 ID 획득 중 오류: $e');
      // 오류 발생 시 UUID fallback
      return await getFallbackDeviceId();
    }
  }

  /// Android 디바이스 ID 획득
  static Future<String> getAndroidDeviceId() async {
    try {
      // android_id 패키지를 사용하여 Settings.Secure.ANDROID_ID 획득
      final androidId = await const AndroidId().getId();
      if (androidId != null && androidId.isNotEmpty && androidId != 'unknown') {
        debugPrint('DeviceUtils: Settings.Secure.ANDROID_ID 사용: $androidId');
        return androidId;
      }
    } catch (e) {
      debugPrint('DeviceUtils: android_id 패키지 오류: $e');
    }

    // Settings.Secure.ANDROID_ID를 가져올 수 없는 경우 fallback
    debugPrint('DeviceUtils: Settings.Secure.ANDROID_ID 없음, fallback ID 사용');
    return await getFallbackDeviceId();
  }

  /// iOS 디바이스 ID 획득
  static Future<String> getIOSDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;

      if (iosInfo.identifierForVendor != null &&
          iosInfo.identifierForVendor!.isNotEmpty) {
        debugPrint(
            'DeviceUtils: identifierForVendor 사용: ${iosInfo.identifierForVendor}');
        return iosInfo.identifierForVendor!;
      }
    } catch (e) {
      debugPrint('DeviceUtils: device_info_plus 패키지 오류: $e');
    }

    // identifierForVendor를 가져올 수 없는 경우 fallback
    debugPrint('DeviceUtils: identifierForVendor 없음, fallback ID 사용');
    return await getFallbackDeviceId();
  }

  /// Fallback UUID 디바이스 ID (다른 플랫폼 또는 오류 시)
  static Future<String> getFallbackDeviceId() async {
    const String cacheKey = 'fallback_device_id';

    // 캐시에서 기존 fallback ID 확인
    final cachedId = CacheService().getString(cacheKey);
    if (cachedId != null && cachedId.isNotEmpty) {
      debugPrint(
          'DeviceUtils: 캐시된 fallback ID 사용: ${cachedId.substring(0, 8)}...');
      return cachedId;
    }

    // 새로운 UUID 생성
    final newId = const Uuid().v4();
    await CacheService().setString(cacheKey, newId);

    debugPrint('DeviceUtils: 새로운 fallback ID 생성: ${newId.substring(0, 8)}...');
    return newId;
  }

  /// 디바이스 ID 유효성 검사
  static bool isValidDeviceId(String deviceId) {
    if (deviceId.isEmpty) return false;

    // 최소 길이 체크
    if (deviceId.length < 8) return false;

    // UUID 패턴 체크
    final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
    if (uuidPattern.hasMatch(deviceId)) {
      return true; // UUID 형식
    }

    // Android ID 패턴 체크 (16자리 hex)
    final androidIdPattern = RegExp(r'^[0-9a-f]{16}');
    if (androidIdPattern.hasMatch(deviceId)) {
      return true; // Android ID 형식
    }

    // 하드웨어 기반 ID 패턴 체크
    if (deviceId.startsWith('android_hw_') || deviceId.startsWith('ios_hw_')) {
      return true;
    }

    return false;
  }

  /// 현재 사용 중인 디바이스 ID 타입 확인
  static Future<String> getDeviceIdType(String deviceId) async {
    if (Platform.isAndroid) {
      try {
        // Settings.Secure.ANDROID_ID 확인
        final androidId = await const AndroidId().getId();
        if (androidId != null &&
            androidId.isNotEmpty &&
            androidId != 'unknown' &&
            deviceId == androidId) {
          return 'Settings.Secure.ANDROID_ID (최우선)';
        }
      } catch (e) {
        debugPrint('DeviceUtils: getDeviceIdType에서 android_id 확인 오류: $e');
      }

      // fallback ID 패턴 확인
      if (deviceId.startsWith('android_fallback_')) {
        return 'Android Fallback ID';
      }
    } else if (Platform.isIOS) {
      try {
        // identifierForVendor 확인
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        if (iosInfo.identifierForVendor != null &&
            iosInfo.identifierForVendor!.isNotEmpty &&
            deviceId == iosInfo.identifierForVendor) {
          return 'identifierForVendor (최우선)';
        }
      } catch (e) {
        debugPrint('DeviceUtils: getDeviceIdType에서 device_info_plus 확인 오류: $e');
      }

      // fallback ID 패턴 확인
      if (deviceId.startsWith('ios_fallback_')) {
        return 'iOS Fallback ID';
      }
    }

    final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
    if (uuidPattern.hasMatch(deviceId)) {
      return 'Fallback UUID';
    }

    return '알 수 없는 타입';
  }

  /// 디바이스 ID 캐시 초기화 (테스트용)
  static Future<void> resetDeviceId() async {
    const String fallbackCacheKey = 'fallback_device_id';
    await CacheService().remove(fallbackCacheKey);
    debugPrint('DeviceUtils: fallback 디바이스 ID 캐시 초기화 완료');
    debugPrint(
        '주의: 실제 디바이스 ID (Android ID, iOS identifierForVendor)는 변경되지 않습니다.');
  }
}
