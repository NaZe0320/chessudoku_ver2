import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 디바이스 고유 식별자 관리 서비스
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();

  factory DeviceService() {
    return _instance;
  }

  DeviceService._internal();

  /// 디바이스 고유 ID 획득
  ///
  /// Android: Android ID 사용
  /// iOS: identifierForVendor 사용
  /// 기타: UUID fallback
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceId();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceId();
      } else {
        // 다른 플랫폼의 경우 UUID fallback
        return await _getFallbackDeviceId();
      }
    } catch (e) {
      debugPrint('DeviceService: 디바이스 ID 획득 중 오류: $e');
      // 오류 발생 시 UUID fallback
      return await _getFallbackDeviceId();
    }
  }

  /// Android 디바이스 ID 획득
  Future<String> _getAndroidDeviceId() async {
    try {
      // android_id 패키지를 사용하여 Settings.Secure.ANDROID_ID 획득
      final androidId = await const AndroidId().getId();
      if (androidId != null && androidId.isNotEmpty && androidId != 'unknown') {
        debugPrint('DeviceService: Settings.Secure.ANDROID_ID 사용: $androidId');
        return androidId;
      }
    } catch (e) {
      debugPrint('DeviceService: android_id 패키지 오류: $e');
    }

    // Settings.Secure.ANDROID_ID를 가져올 수 없는 경우 fallback
    debugPrint('DeviceService: Settings.Secure.ANDROID_ID 없음, fallback ID 생성');

    // 간단한 fallback ID 생성 (타임스탬프 + 랜덤값)
    final fallbackId =
        'android_fallback_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    debugPrint('DeviceService: 생성된 fallback ID: $fallbackId');

    return fallbackId;
  }

  /// iOS 디바이스 ID 획득
  Future<String> _getIOSDeviceId() async {
    // device_info_plus 없이 간단한 fallback ID 생성
    debugPrint('DeviceService: iOS에서 identifierForVendor 없음, fallback ID 생성');

    // 간단한 fallback ID 생성 (타임스탬프 + 랜덤값)
    final fallbackId =
        'ios_fallback_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    debugPrint('DeviceService: 생성된 iOS fallback ID: $fallbackId');

    return fallbackId;
  }

  /// Fallback UUID 디바이스 ID (다른 플랫폼 또는 오류 시)
  Future<String> _getFallbackDeviceId() async {
    const String cacheKey = 'fallback_device_id';

    // 캐시에서 기존 fallback ID 확인
    final cachedId = CacheService().getString(cacheKey);
    if (cachedId != null && cachedId.isNotEmpty) {
      debugPrint(
          'DeviceService: 캐시된 fallback ID 사용: ${cachedId.substring(0, 8)}...');
      return cachedId;
    }

    // 새로운 UUID 생성
    final newId = const Uuid().v4();
    await CacheService().setString(cacheKey, newId);

    debugPrint(
        'DeviceService: 새로운 fallback ID 생성: ${newId.substring(0, 8)}...');
    return newId;
  }

  /// 디바이스 정보 획득 (디버깅용)
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceId = await getDeviceId();

    Map<String, dynamic> platformInfo = {};

    if (Platform.isAndroid) {
      // Settings.Secure.ANDROID_ID 정보만 포함
      String? secureAndroidId;
      try {
        secureAndroidId = await const AndroidId().getId();
      } catch (e) {
        secureAndroidId = '오류: $e';
      }

      platformInfo = {
        'platform': 'Android',
        'secureAndroidId': secureAndroidId,
        'deviceId': deviceId,
      };
    } else if (Platform.isIOS) {
      platformInfo = {
        'platform': 'iOS',
        'deviceId': deviceId,
      };
    } else {
      platformInfo = {
        'platform': Platform.operatingSystem,
        'deviceId': deviceId,
      };
    }

    return {
      'deviceId': deviceId,
      'platformInfo': platformInfo,
    };
  }

  /// 디바이스 ID 캐시 초기화 (테스트용)
  /// 주의: 실제 디바이스 ID는 변경되지 않고, fallback UUID만 초기화됨
  Future<void> resetDeviceId() async {
    const String fallbackCacheKey = 'fallback_device_id';
    await CacheService().remove(fallbackCacheKey);
    debugPrint('DeviceService: fallback 디바이스 ID 캐시 초기화 완료');
    debugPrint(
        '주의: 실제 디바이스 ID (Android ID, iOS identifierForVendor)는 변경되지 않습니다.');
  }

  /// 디바이스 ID 유효성 검사
  bool isValidDeviceId(String deviceId) {
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
  Future<String> getDeviceIdType() async {
    final deviceId = await getDeviceId();

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
        debugPrint('DeviceService: getDeviceIdType에서 android_id 확인 오류: $e');
      }

      // fallback ID 패턴 확인
      if (deviceId.startsWith('android_fallback_')) {
        return 'Android Fallback ID';
      }
    } else if (Platform.isIOS) {
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
}
