import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/domain/notifiers/game_notifier.dart';
import 'package:chessudoku/ui/common/widgets/selection_dialog.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';

class CheckpointButton extends HookConsumerWidget {
  final bool isPaused;

  const CheckpointButton({super.key, this.isPaused = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return GestureDetector(
      onTap: isPaused
          ? null
          : () => _showCheckpointBottomSheet(context, ref, translate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPaused ? Colors.grey[100] : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPaused ? Colors.grey[200]! : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark,
              color: isPaused ? Colors.grey[400] : Colors.grey[700],
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              translate('checkpoint', '분기점'),
              style: TextStyle(
                color: isPaused ? Colors.grey[400] : Colors.grey[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more,
              color: isPaused ? Colors.grey[400] : Colors.grey[700],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckpointBottomSheet(
      BuildContext context, WidgetRef ref, Function translate) {
    final gameState = ref.watch(gameNotifierProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들바
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // 제목
                Text(
                  translate('checkpoint_management', '분기점 관리'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // 분기점 목록
                ...List.generate(
                  3,
                  (index) => _buildCheckpointItem(
                    context,
                    ref,
                    translate,
                    index + 1,
                    'checkpoint_$index',
                    gameState.checkpoints['checkpoint_$index'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckpointItem(
    BuildContext context,
    WidgetRef ref,
    Function translate,
    int index,
    String checkpointId,
    checkpoint,
  ) {
    final hasSave = checkpoint != null;
    final notifier = ref.read(gameNotifierProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasSave ? Colors.grey[100] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasSave ? Colors.grey[300]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasSave ? Icons.bookmark : Icons.bookmark_border,
            color: hasSave ? Colors.blue : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${translate('checkpoint', '분기점')} $index',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasSave ? Colors.black : Colors.grey,
                  ),
                ),
                if (hasSave) ...[
                  const SizedBox(height: 2),
                  Text(
                    checkpoint.formattedElapsedTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    '비어있음',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              // 저장 버튼 (아이콘만)
              IconButton(
                onPressed: () {
                  if (hasSave) {
                    // 이미 저장된 경우 덮어쓰기 확인
                    _showOverwriteDialog(
                        context, ref, translate, checkpointId, notifier);
                  } else {
                    // 새로 저장
                    notifier.handleIntent(CreateCheckpointIntent(checkpointId));
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save, size: 20),
                tooltip: translate('save', '저장'),
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              // 불러오기 버튼 (아이콘만)
              IconButton(
                onPressed: hasSave
                    ? () {
                        // 복원 확인 다이얼로그
                        _showRestoreDialog(
                            context, ref, translate, checkpointId, notifier);
                      }
                    : null,
                icon: const Icon(Icons.restore, size: 20),
                tooltip: translate('load', '불러오기'),
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOverwriteDialog(BuildContext context, WidgetRef ref,
      Function translate, String checkpointId, GameNotifier notifier) {
    SelectionDialog.show(
      context: context,
      title: translate('overwrite_checkpoint', '분기점 덮어쓰기'),
      message: translate('overwrite_checkpoint_message', '이 분기점을 덮어쓰시겠습니까?'),
      cancelText: translate('cancel', '취소'),
      confirmText: translate('overwrite', '덮어쓰기'),
      confirmColor: AppColors.error,
    ).then((confirmed) {
      if (confirmed == true) {
        notifier.handleIntent(CreateCheckpointIntent(checkpointId));
        if (context.mounted) {
          Navigator.of(context).pop(); // 하단 시트 닫기
        }
      }
    });
  }

  void _showRestoreDialog(BuildContext context, WidgetRef ref,
      Function translate, String checkpointId, GameNotifier notifier) {
    SelectionDialog.show(
      context: context,
      title: translate('restore_checkpoint', '분기점 복원'),
      message: translate('restore_checkpoint_message', '이 분기점을 복원하시겠습니까?'),
      cancelText: translate('cancel', '취소'),
      confirmText: translate('restore', '복원'),
      confirmColor: AppColors.primary,
    ).then((confirmed) {
      if (confirmed == true) {
        notifier.handleIntent(RestoreCheckpointIntent(checkpointId));
        if (context.mounted) {
          Navigator.of(context).pop(); // 하단 시트 닫기
        }
      }
    });
  }
}
