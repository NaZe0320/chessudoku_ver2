import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class QuickPlayButton extends StatelessWidget {
  final Difficulty difficulty;
  final Function(Difficulty) onTap;
  final bool isPremium;

  const QuickPlayButton({
    super.key,
    required this.difficulty,
    required this.onTap,
    this.isPremium = false,
  });

  bool get isLocked => difficulty == Difficulty.expert && !isPremium;
  bool get isExpertPremium => difficulty == Difficulty.expert;

  @override
  Widget build(BuildContext context) {
    final chessPiece = ChessPiece.fromDifficulty(difficulty);
    final difficultyColor = _getDifficultyColor(difficulty);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLocked ? null : () => onTap(difficulty),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: isLocked ? Colors.grey : difficultyColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isLocked
                ? Colors.grey.withValues(alpha: 0.3)
                : difficultyColor.withValues(alpha: 0.2),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chessPiece.symbol,
                      style: TextStyle(
                        fontSize: 32,
                        color: isLocked ? Colors.grey : AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDifficultyName(difficulty),
                      style: TextStyle(
                        color: isLocked ? Colors.grey : AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDifficultyDescription(difficulty),
                      style: TextStyle(
                        color: isLocked ? Colors.grey : AppColors.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              if (isExpertPremium && !isLocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50); // 초록색
      case Difficulty.medium:
        return const Color(0xFFFF9800); // 주황색
      case Difficulty.hard:
        return const Color(0xFFF44336); // 빨간색
      case Difficulty.expert:
        return const Color(0xFF9C27B0); // 보라색
    }
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '쉬움';
      case Difficulty.medium:
        return '보통';
      case Difficulty.hard:
        return '어려움';
      case Difficulty.expert:
        return '전문가';
    }
  }

  String _getDifficultyDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '폰 · 입문자용';
      case Difficulty.medium:
        return '나이트 · 적당한 도전';
      case Difficulty.hard:
        return '비숍 · 도전적인';
      case Difficulty.expert:
        return '퀸 · 최고 난이도';
    }
  }
}
