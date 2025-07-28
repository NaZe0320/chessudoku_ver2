import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/data/models/puzzle_record.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/typography.dart';
import 'package:chessudoku/ui/theme/dimensions.dart';

class GameRecordsScreen extends HookConsumerWidget {
  const GameRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);
    final puzzleRecordRepository = ref.watch(puzzleRecordRepositoryProvider);
    final selectedDifficulty = useState<Difficulty?>(null);
    final records = useState<List<PuzzleRecord>>([]);
    final isLoading = useState(true);

    Future<void> loadRecords() async {
      isLoading.value = true;
      try {
        List<PuzzleRecord> loadedRecords;
        if (selectedDifficulty.value != null) {
          loadedRecords = await puzzleRecordRepository
              .getRecordsByDifficulty(selectedDifficulty.value!);
        } else {
          loadedRecords = await puzzleRecordRepository.getAllRecords();
        }
        // 최신 기록부터 정렬
        loadedRecords.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        records.value = loadedRecords;
      } catch (e) {
        records.value = [];
      } finally {
        isLoading.value = false;
      }
    }

    // 기록 로드
    useEffect(() {
      loadRecords();
      return null;
    }, [selectedDifficulty.value]);

    String formatTime(int seconds) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final remainingSeconds = seconds % 60;

      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      } else {
        return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      }
    }

    String formatDate(DateTime date) {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }

    String getDifficultyText(Difficulty difficulty) {
      switch (difficulty) {
        case Difficulty.easy:
          return translate('easy_difficulty', '쉬움');
        case Difficulty.medium:
          return translate('normal_difficulty', '보통');
        case Difficulty.hard:
          return translate('hard_difficulty', '어려움');
        case Difficulty.expert:
          return translate('expert_difficulty', '전문가');
      }
    }

    Color getDifficultyColor(Difficulty difficulty) {
      switch (difficulty) {
        case Difficulty.easy:
          return Colors.green;
        case Difficulty.medium:
          return Colors.orange;
        case Difficulty.hard:
          return Colors.red;
        case Difficulty.expert:
          return Colors.purple;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        title: Text(translate('game_records', '게임 기록')),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 필터 버튼들
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label: translate('all_difficulty', '전체'),
                        isSelected: selectedDifficulty.value == null,
                        onTap: () => selectedDifficulty.value = null,
                      ),
                    ),
                    const SizedBox(width: Spacing.space2),
                    Expanded(
                      child: _FilterChip(
                        label: translate('easy_difficulty', '쉬움'),
                        isSelected: selectedDifficulty.value == Difficulty.easy,
                        onTap: () => selectedDifficulty.value = Difficulty.easy,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: Spacing.space2),
                    Expanded(
                      child: _FilterChip(
                        label: translate('normal_difficulty', '보통'),
                        isSelected:
                            selectedDifficulty.value == Difficulty.medium,
                        onTap: () =>
                            selectedDifficulty.value = Difficulty.medium,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: Spacing.space2),
                    Expanded(
                      child: _FilterChip(
                        label: translate('hard_difficulty', '어려움'),
                        isSelected: selectedDifficulty.value == Difficulty.hard,
                        onTap: () => selectedDifficulty.value = Difficulty.hard,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // 기록 목록
              Expanded(
                child: isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.textWhite,
                        ),
                      )
                    : records.value.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(Spacing.space6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(Spacing.radiusLg),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 64,
                                    color: AppColors.textWhite
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(height: Spacing.space4),
                                  Text(
                                    translate('no_records', '기록이 없습니다'),
                                    style: AppTypography.heading2.copyWith(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.space2),
                                  Text(
                                    translate('complete_puzzles_to_see_records',
                                        '퍼즐을 완료하면 기록이 표시됩니다'),
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textWhite
                                          .withValues(alpha: 0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            itemCount: records.value.length,
                            itemBuilder: (context, index) {
                              final record = records.value[index];
                              return _RecordCard(
                                record: record,
                                formatTime: formatTime,
                                formatDate: formatDate,
                                getDifficultyText: getDifficultyText,
                                getDifficultyColor: getDifficultyColor,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.space2,
          horizontal: Spacing.space3,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.textWhite)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected
                ? (color != null ? Colors.white : AppColors.primary)
                : AppColors.textWhite,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final PuzzleRecord record;
  final String Function(int) formatTime;
  final String Function(DateTime) formatDate;
  final String Function(Difficulty) getDifficultyText;
  final Color Function(Difficulty) getDifficultyColor;

  const _RecordCard({
    required this.record,
    required this.formatTime,
    required this.formatDate,
    required this.getDifficultyText,
    required this.getDifficultyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.space3),
      padding: const EdgeInsets.all(Spacing.space4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 난이도 표시
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: getDifficultyColor(record.difficulty),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: Spacing.space3),

          // 기록 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.space2,
                        vertical: Spacing.space1,
                      ),
                      decoration: BoxDecoration(
                        color: getDifficultyColor(record.difficulty)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                        border: Border.all(
                          color: getDifficultyColor(record.difficulty)
                              .withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        getDifficultyText(record.difficulty),
                        style: AppTypography.caption.copyWith(
                          color: getDifficultyColor(record.difficulty),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatDate(record.completedAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.space2),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: Spacing.space1),
                    Text(
                      formatTime(record.elapsedSeconds),
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (record.hintCount > 0) ...[
                      const SizedBox(width: Spacing.space3),
                      Icon(
                        Icons.lightbulb,
                        size: 16,
                        color: Colors.orange.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: Spacing.space1),
                      Text(
                        '${record.hintCount}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.orange.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
