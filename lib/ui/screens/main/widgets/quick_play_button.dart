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
    final difficultyColor = difficulty.color;

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
                      difficulty.label,
                      style: TextStyle(
                        color: isLocked ? Colors.grey : AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty.description,
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
}
