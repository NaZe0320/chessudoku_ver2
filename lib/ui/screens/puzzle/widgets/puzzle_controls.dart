import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/common/widgets/app_neomorphic_button.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleControls extends ConsumerWidget {
  const PuzzleControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleProvider);
    final intent = ref.read(puzzleIntentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              // 되돌리기 버튼
              AppNeomorphicButton(
                text: '되돌리기',
                prefixIcon: Icon(
                  Icons.undo,
                  color: puzzleState.canUndo
                      ? AppColors.primary
                      : AppColors.neutral400,
                  size: 18,
                ),
                onTap: puzzleState.canUndo ? () => intent.undoAction() : null,
                type: NeomorphicButtonType.primary,
                size: NeomorphicButtonSize.small,
                borderRadius: 12,
              ),

              // 메모 모드 토글 버튼
              AppNeomorphicButton(
                text: '메모',
                prefixIcon: Icon(
                  Icons.edit_note,
                  color: puzzleState.isNoteMode
                      ? AppColors.primary
                      : AppColors.neutral700,
                  size: 18,
                ),
                onTap: () => intent.toggleNoteMode(),
                type: NeomorphicButtonType.primary,
                size: NeomorphicButtonSize.small,
                borderRadius: 12,
                isActive: puzzleState.isNoteMode,
              ),

              // 다시 실행 버튼
              AppNeomorphicButton(
                text: '다시 실행',
                prefixIcon: Icon(
                  Icons.redo,
                  color: puzzleState.canRedo
                      ? AppColors.primary
                      : AppColors.neutral400,
                  size: 18,
                ),
                onTap: puzzleState.canRedo ? () => intent.redoAction() : null,
                type: NeomorphicButtonType.primary,
                size: NeomorphicButtonSize.small,
                borderRadius: 12,
              ),

              // 메모 자동 채우기 버튼
              AppNeomorphicButton(
                text: '자동 메모',
                prefixIcon: const Icon(
                  Icons.auto_fix_high,
                  color: AppColors.neutral700,
                  size: 18,
                ),
                onTap: () => intent.fillNotes(),
                type: NeomorphicButtonType.primary,
                size: NeomorphicButtonSize.small,
                borderRadius: 12,
              ),

              // 오류 검사 버튼
              AppNeomorphicButton(
                text: '오류 검사',
                prefixIcon: Icon(
                  Icons.check_circle_outline,
                  color: puzzleState.errorCells.isNotEmpty
                      ? AppColors.error
                      : AppColors.neutral700,
                  size: 18,
                ),
                onTap: () {
                  intent.checkErrors();
                  final errorCount = puzzleState.errorCells.length;
                  if (errorCount > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$errorCount개의 오류가 있습니다.'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('오류가 없습니다! 잘하고 있어요.'),
                        backgroundColor: Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(8),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                type: NeomorphicButtonType.primary,
                size: NeomorphicButtonSize.small,
                borderRadius: 12,
                isActive: puzzleState.errorCells.isNotEmpty,
              ),

              // 분기점 저장/불러오기 버튼
              AppNeomorphicButton(
                text: '분기점',
                prefixIcon: const Icon(
                  Icons.save_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.neutral700,
                  size: 18,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '분기점 저장/불러오기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(3, (slot) {
                            final hasState = intent.hasStateInSlot(slot);
                            final saveTime = intent.getSaveTimeInSlot(slot);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '슬롯 ${slot + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.neutral900,
                                          ),
                                        ),
                                        if (hasState) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            saveTime ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.neutral700,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 저장 버튼
                                      IconButton(
                                        icon: const Icon(Icons.save_outlined),
                                        color: AppColors.primary,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          intent.saveToSlot(slot);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '슬롯 ${slot + 1}에 저장되었습니다.'),
                                              backgroundColor:
                                                  AppColors.primary,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(8),
                                              duration:
                                                  const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                      // 불러오기 버튼
                                      IconButton(
                                        icon: const Icon(Icons.restore),
                                        color: hasState
                                            ? AppColors.primary
                                            : AppColors.neutral400,
                                        onPressed: hasState
                                            ? () {
                                                Navigator.pop(context);
                                                intent.loadFromSlot(slot);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        '슬롯 ${slot + 1}에서 불러왔습니다.'),
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin:
                                                        const EdgeInsets.all(8),
                                                    duration: const Duration(
                                                        seconds: 1),
                                                  ),
                                                );
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
                type: NeomorphicButtonType.primary,
                size: NeomorphicButtonSize.small,
                borderRadius: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
