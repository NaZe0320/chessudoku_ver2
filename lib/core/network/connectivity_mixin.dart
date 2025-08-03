import 'package:chessudoku/core/network/network_service.dart';
import 'package:chessudoku/ui/common/widgets/offline_dialog.dart';
import 'package:chessudoku/data/services/api_service.dart';
import 'package:flutter/material.dart';

/// 네트워크 연결 상태를 확인하는 Mixin
mixin ConnectivityMixin {
  final NetworkService _networkService = NetworkService();

  /// 현재 연결 상태 확인
  Future<bool> checkConnectivity() => _networkService.checkConnectivity();

  /// 인터넷 연결 확인 후 오프라인 다이얼로그 표시 (일괄 처리)
  Future<bool> checkConnectivityWithDialog(
    BuildContext context, {
    String title = '인터넷 연결 필요',
    String message = '이 기능을 사용하려면 인터넷 연결이 필요합니다.',
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    final isOnline = await checkConnectivity();

    if (!isOnline) {
      // mounted 체크 추가
      if (context.mounted) {
        // 오프라인 다이얼로그 표시
        await OfflineDialog.show(
          context: context,
          title: title,
          message: message,
          onRetry: onRetry,
          onCancel: onCancel,
        );
      }
      return false;
    }

    return true;
  }

  /// 인터넷 연결 확인 후 콜백 실행 (간단한 버전)
  Future<bool> checkConnectivityAndExecute(
    BuildContext context,
    Future<void> Function() onOnline, {
    String title = '인터넷 연결 필요',
    String message = '이 기능을 사용하려면 인터넷 연결이 필요합니다.',
  }) async {
    final isOnline = await checkConnectivity();

    if (!isOnline) {
      if (context.mounted) {
        await OfflineDialog.show(
          context: context,
          title: title,
          message: message,
          onRetry: () async {
            // 재시도 시 다시 연결 확인
            final retryOnline = await checkConnectivity();
            if (retryOnline && context.mounted) {
              await onOnline();
            }
          },
        );
      }
      return false;
    }

    await onOnline();
    return true;
  }

  /// API 호출 시 오프라인 처리 (BuildContext 없이)
  Future<T?> executeApiCall<T>(
    Future<T> Function() apiCall, {
    String errorMessage = '인터넷 연결이 필요합니다.',
  }) async {
    try {
      final isOnline = await checkConnectivity();
      if (!isOnline) {
        throw ApiException(errorMessage, 0);
      }

      return await apiCall();
    } on ApiException catch (e) {
      // 오프라인 에러는 상위에서 처리하도록 rethrow
      rethrow;
    } catch (e) {
      // 기타 에러는 일반적인 API 에러로 변환
      throw const ApiException('네트워크 오류가 발생했습니다.', null);
    }
  }

  /// API 호출 시 오프라인 다이얼로그 표시 (BuildContext 필요)
  Future<T?> executeApiCallWithDialog<T>(
    BuildContext context,
    Future<T> Function() apiCall, {
    String title = '인터넷 연결 필요',
    String message = '이 기능을 사용하려면 인터넷 연결이 필요합니다.',
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    try {
      final isOnline = await checkConnectivity();
      if (!isOnline) {
        if (context.mounted) {
          await OfflineDialog.show(
            context: context,
            title: title,
            message: message,
            onRetry: onRetry,
            onCancel: onCancel,
          );
        }
        return null;
      }

      return await apiCall();
    } catch (e) {
      // 기타 에러는 일반적인 API 에러로 변환
      throw const ApiException('네트워크 오류가 발생했습니다.', null);
    }
  }
}
