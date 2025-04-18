// lib/core/utils/loading_manager.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';

class LoadingManager {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static OverlayEntry? _overlayEntry;

  static void showLoading({String? message}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Overlay가 있는지 확인
    if (!_hasOverlayContext(context)) return;

    hideLoading(); // 이미 표시된 로딩이 있다면 제거

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: AppColors.neutral900.withAlpha(175),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: AppColors.neutral800,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final overlay = Overlay.of(context);
      if (_overlayEntry != null) {
        overlay.insert(_overlayEntry!);
      }
    } catch (e) {
      debugPrint('로딩 표시 중 오류 발생: $e');
    }
  }

  static void hideLoading() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static bool _hasOverlayContext(BuildContext context) {
    try {
      Overlay.of(context);
      return true;
    } catch (e) {
      return false;
    }
  }
}
