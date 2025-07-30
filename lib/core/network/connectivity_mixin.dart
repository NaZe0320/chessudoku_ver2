import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'network_service.dart';

/// 위젯에서 네트워크 상태를 쉽게 사용할 수 있는 mixin
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  NetworkService get _networkService => NetworkService();

  /// 현재 온라인 상태
  bool get isOnline => _networkService.isOnline;

  /// 네트워크 상태 스트림
  Stream<bool> get connectionStatusStream =>
      _networkService.connectionStatusStream;

  /// 네트워크 상태 확인
  Future<bool> checkConnectivity() => _networkService.checkConnectivity();
}

/// Hook을 사용하는 위젯용 네트워크 상태 hook
bool useNetworkStatus() {
  final networkService = NetworkService();
  final isOnline = useState(networkService.isOnline);

  useEffect(() {
    final subscription = networkService.connectionStatusStream.listen(
      (bool online) {
        isOnline.value = online;
      },
    );

    return subscription.cancel;
  }, []);

  return isOnline.value;
}
