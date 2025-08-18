import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';

// TODO: MVI 아키텍처 리팩토링 필요
// - 싱글톤 패턴 제거하고 Provider 기반으로 변경
// - 상태 관리를 NetworkNotifier로 이동
// - lib/data/services/로 이동 고려
/// 네트워크 연결 상태를 관리하는 서비스
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// 현재 온라인 상태
  bool get isOnline => _isOnline;

  /// 연결 상태 스트림
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// 네트워크 상태 모니터링 시작
  Future<void> initialize() async {
    try {
      // 초기 상태 확인
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // 상태 변화 모니터링
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) {
          _updateConnectionStatus(result);
        },
      );

      developer.log('네트워크 서비스 초기화 완료', name: 'NetworkService');
    } catch (e) {
      developer.log('네트워크 서비스 초기화 실패: $e', name: 'NetworkService');
    }
  }

  /// 연결 상태 업데이트
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    developer.log('네트워크 상태 변경: ${result.name} (온라인: $_isOnline)',
        name: 'NetworkService');

    // 상태가 변경된 경우에만 스트림에 전송
    if (wasOnline != _isOnline) {
      _connectionStatusController.add(_isOnline);
    }
  }

  /// 현재 연결 상태 확인
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isOnline;
    } catch (e) {
      developer.log('연결 상태 확인 실패: $e', name: 'NetworkService');
      return false;
    }
  }

  /// 리소스 정리
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
