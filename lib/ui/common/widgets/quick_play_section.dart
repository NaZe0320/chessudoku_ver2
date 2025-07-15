import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuickPlaySection extends HookConsumerWidget {
  const QuickPlaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.flash_on,
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              translate('quick_play', '빠른 플레이'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          translate('quick_play_description', '난이도를 선택하여 바로 시작할 수 있는 랜덤 퍼즐'),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // 태블릿/폴드 판단 (600px 이상)
            final isTablet = constraints.maxWidth >= 600;

            if (isTablet) {
              // 태블릿: 1x4 배치
              return const Row(
                children: [
                  Expanded(
                      child: _QuickPlayButton(chessPiece: ChessPiece.rook)),
                  SizedBox(width: 12),
                  Expanded(
                      child: _QuickPlayButton(chessPiece: ChessPiece.knight)),
                  SizedBox(width: 12),
                  Expanded(
                      child: _QuickPlayButton(chessPiece: ChessPiece.bishop)),
                  SizedBox(width: 12),
                  Expanded(
                      child: _QuickPlayButton(chessPiece: ChessPiece.queen)),
                ],
              );
            } else {
              // 모바일: 2x2 배치
              return const Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _QuickPlayButton(chessPiece: ChessPiece.rook)),
                      SizedBox(width: 12),
                      Expanded(
                          child:
                              _QuickPlayButton(chessPiece: ChessPiece.knight)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child:
                              _QuickPlayButton(chessPiece: ChessPiece.bishop)),
                      SizedBox(width: 12),
                      Expanded(
                          child:
                              _QuickPlayButton(chessPiece: ChessPiece.queen)),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class _QuickPlayButton extends HookConsumerWidget {
  final ChessPiece chessPiece;

  const _QuickPlayButton({
    required this.chessPiece,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);
    final isPro =
        chessPiece == ChessPiece.bishop || chessPiece == ChessPiece.queen;

    return Container(
      decoration: BoxDecoration(
        color: isPro
            ? AppColors.surface.withValues(alpha: 0.5)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPro
              ? null
              : () {
                  // TODO: 빠른 플레이 시작 로직
                },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _getChessPieceIcon(),
                      size: 32,
                      color: isPro ? AppColors.textTertiary : _getIconColor(),
                    ),
                    if (isPro)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 12,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getChessPieceName(translate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isPro ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getDifficultyText(translate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isPro
                        ? AppColors.textTertiary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    switch (chessPiece) {
      case ChessPiece.rook:
        return AppColors.success;
      case ChessPiece.knight:
        return AppColors.accent;
      case ChessPiece.bishop:
        return AppColors.textTertiary;
      case ChessPiece.queen:
        return AppColors.textTertiary;
      default:
        return AppColors.primary;
    }
  }

  Color _getIconColor() {
    switch (chessPiece) {
      case ChessPiece.rook:
        return AppColors.success;
      case ChessPiece.knight:
        return AppColors.accent;
      case ChessPiece.bishop:
        return AppColors.primary;
      case ChessPiece.queen:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getChessPieceIcon() {
    switch (chessPiece) {
      case ChessPiece.rook:
        return Icons.castle; // 폰 대신 룩(성)
      case ChessPiece.knight:
        return Icons.whatshot; // 나이트 (말)
      case ChessPiece.bishop:
        return Icons.local_fire_department; // 비숍
      case ChessPiece.queen:
        return Icons.stars; // 퀸
      default:
        return Icons.gamepad;
    }
  }

  String _getChessPieceName(String Function(String, String) translate) {
    switch (chessPiece) {
      case ChessPiece.rook:
        return translate('easy', '쉬움');
      case ChessPiece.knight:
        return translate('normal', '보통');
      case ChessPiece.bishop:
        return translate('hard', '어려움');
      case ChessPiece.queen:
        return translate('expert', '전문가');
      default:
        return translate('unknown', '알 수 없음');
    }
  }

  String _getDifficultyText(String Function(String, String) translate) {
    switch (chessPiece) {
      case ChessPiece.rook:
        return translate('beginner_friendly', '입문자용');
      case ChessPiece.knight:
        return translate('balanced_challenge', '적당한 도전');
      case ChessPiece.bishop:
        return translate('challenging', '도전적인');
      case ChessPiece.queen:
        return translate('expert_level', '전문가 수준');
      default:
        return '';
    }
  }
}
