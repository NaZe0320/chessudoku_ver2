import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// 앱 전체에서 사용할 수 있는 캐시 서비스
/// SharedPreferences를 싱글톤 패턴으로 래핑한 클래스
class CacheService {
  static final CacheService _instance = CacheService._internal();
  SharedPreferences? _prefs;

  // 싱글톤 패턴 적용
  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  /// 캐시 서비스 초기화
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 문자열 값 저장
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _prefs!.setString(key, value);
  }

  /// 문자열 값 로드
  String? getString(String key) {
    _ensureInitializedSync();
    return _prefs?.getString(key);
  }

  /// 정수 값 저장
  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return await _prefs!.setInt(key, value);
  }

  /// 정수 값 로드
  int? getInt(String key) {
    _ensureInitializedSync();
    return _prefs?.getInt(key);
  }

  /// 불리언 값 저장
  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return await _prefs!.setBool(key, value);
  }

  /// 불리언 값 로드
  bool? getBool(String key) {
    _ensureInitializedSync();
    return _prefs?.getBool(key);
  }

  /// 더블 값 저장
  Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return await _prefs!.setDouble(key, value);
  }

  /// 더블 값 로드
  double? getDouble(String key) {
    _ensureInitializedSync();
    return _prefs?.getDouble(key);
  }

  /// 문자열 리스트 저장
  Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return await _prefs!.setStringList(key, value);
  }

  /// 문자열 리스트 로드
  List<String>? getStringList(String key) {
    _ensureInitializedSync();
    return _prefs?.getStringList(key);
  }

  /// 지정된 키의 데이터 존재 여부 확인
  bool containsKey(String key) {
    developer.log('containsKey 호출: $key', name: 'CacheService');
    _ensureInitializedSync();
    final result = _prefs?.containsKey(key) ?? false;
    developer.log('containsKey 결과: $result', name: 'CacheService');
    return result;
  }

  /// 지정된 키의 데이터 삭제
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _prefs!.remove(key);
  }

  /// 모든 데이터 삭제
  Future<bool> clear() async {
    await _ensureInitialized();
    return await _prefs!.clear();
  }

  /// 서비스가 초기화되었는지 확인하고 초기화되지 않았으면 초기화
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  /// 동기적으로 초기화 여부 확인 (값을 읽을 때 사용)
  void _ensureInitializedSync() {
    if (_prefs == null) {
      throw StateError('CacheService가 초기화되지 않았습니다. 사용하기 전에 init()을 호출하세요.');
    }
  }
}
