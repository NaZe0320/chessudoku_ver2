import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerErrorScreen extends ConsumerWidget {
  const ServerErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight,
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 영역: 에러 아이콘 (메인 테마와 동일한 스타일)
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 56,
                      ),
                    ),
                  ),

                  // 중앙 영역: 텍스트 정보
                  Column(
                    children: [
                      Text(
                        '서버 연결 오류',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // 하단 영역: 추가 안내 텍스트
                  Column(
                    children: [
                      Text(
                        '잠시 후 다시 시도해주세요',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '문제가 지속될 경우 앱을 다시 시작해주세요',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.6),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
