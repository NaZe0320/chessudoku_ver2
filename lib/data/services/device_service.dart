import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 디바이스 고유 식별자 관리 서비스
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const String _deviceIdKey = 'device_unique_id';
  
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
    final androidInfo = await _deviceInfo.androidInfo;
    
    // Android ID 사용 (가장 안정적)
    final androidId = androidInfo.id;
    if (androidId.isNotEmpty && androidId != 'unknown') {
      debugPrint('DeviceService: Android ID 사용: ${androidId.substring(0, 8)}...');
      return androidId;
    }
    
    // Android ID가 없는 경우 하드웨어 기반 ID 생성
    debugPrint('DeviceService: Android ID 없음, 하드웨어 정보 기반 ID 생성');
    final hardwareId = _generateHardwareBasedId([
      androidInfo.brand,
      androidInfo.model,
      androidInfo.device,   
      androidInfo.product,
      androidInfo.hardware,
      androidInfo.bootloader,
      androidInfo.board,
    ]);
    
    return 'android_hw_$hardwareId';
  }

  /// iOS 디바이스 ID 획득
  Future<String> _getIOSDeviceId() async {
    final iosInfo = await _deviceInfo.iosInfo;
    
    // identifierForVendor 사용 (앱 벤더별 고유 ID)
    final vendorId = iosInfo.identifierForVendor;
    if (vendorId != null && vendorId.isNotEmpty) {
      debugPrint('DeviceService: iOS identifierForVendor 사용: ${vendorId.substring(0, 8)}...');
      return vendorId;
    }
    
    // identifierForVendor가 없는 경우 하드웨어 정보 기반 ID 생성
    debugPrint('DeviceService: identifierForVendor 없음, 하드웨어 정보 기반 ID 생성');
    final hardwareId = _generateHardwareBasedId([
      iosInfo.model,
      iosInfo.systemName,
      iosInfo.systemVersion,
      iosInfo.name,
      iosInfo.localizedModel,
      iosInfo.utsname.machine,
    ]);
    
    return 'ios_hw_$hardwareId';
  }

  /// 하드웨어 정보 기반 ID 생성
  String _generateHardwareBasedId(List<String> hardwareInfo) {
    final validInfo = hardwareInfo.where((info) => info.isNotEmpty).join('_');
    return validInfo.hashCode.abs().toString();
  }

  /// Fallback UUID 디바이스 ID (다른 플랫폼 또는 오류 시)
  Future<String> _getFallbackDeviceId() async {
    const String cacheKey = 'fallback_device_id';
    
    // 캐시에서 기존 fallback ID 확인
    final cachedId = CacheService().getString(cacheKey);
    if (cachedId != null && cachedId.isNotEmpty) {
      debugPrint('DeviceService: 캐시된 fallback ID 사용: ${cachedId.substring(0, 8)}...');
      return cachedId;
    }
    
    // 새로운 UUID 생성
    final newId = const Uuid().v4();
    await CacheService().setString(cacheKey, newId);
    
    debugPrint('DeviceService: 새로운 fallback ID 생성: ${newId.substring(0, 8)}...');
    return newId;
  }

  /// 디바이스 정보 획득 (디버깅용)
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceId = await getDeviceId();
    
    Map<String, dynamic> platformInfo = {};
    
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      platformInfo = {
        'platform': 'Android',
        'androidId': androidInfo.id,
        'brand': androidInfo.brand,
        'model': androidInfo.model,
        'device': androidInfo.device,
        'product': androidInfo.product,
        'hardware': androidInfo.hardware,
        'bootloader': androidInfo.bootloader,
        'board': androidInfo.board,
        'version': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      platformInfo = {
        'platform': 'iOS',
        'identifierForVendor': iosInfo.identifierForVendor,
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'localizedModel': iosInfo.localizedModel,
        'machine': iosInfo.utsname.machine,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
      };
    } else {
      final deviceInfo = await _deviceInfo.deviceInfo;
      platformInfo = {
        'platform': Platform.operatingSystem,
        'data': deviceInfo.data,
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
    debugPrint('주의: 실제 디바이스 ID (Android ID, iOS identifierForVendor)는 변경되지 않습니다.');
  }


/// 디바이스 ID 유효성 검사
  bool isValidDeviceId(String deviceId) {
    if (deviceId.isEmpty) return false;
    
    // 최소 길이 체크
    if (deviceId.length < 8) return false;
    
    // UUID 패턴 체크
    final uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
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
      final androidInfo = await _deviceInfo.androidInfo;
      if (deviceId == androidInfo.id) {
        return 'Android ID (권장)';
      } else if (deviceId.startsWith('android_hw_')) {
        return 'Android 하드웨어 기반 ID';
      }
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      if (deviceId == iosInfo.identifierForVendor) {
        return 'iOS identifierForVendor (권장)';
      } else if (deviceId.startsWith('ios_hw_')) {
        return 'iOS 하드웨어 기반 ID';
      }
    }
    
    final uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
    if (uuidPattern.hasMatch(deviceId)) {
      return 'Fallback UUID';
    }
    
    return '알 수 없는 타입';
  }
}