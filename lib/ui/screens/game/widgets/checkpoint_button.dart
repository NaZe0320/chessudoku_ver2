import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';

class CheckpointButton extends HookConsumerWidget {
  const CheckpointButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return GestureDetector(
      onTap: () => _showCheckpointBottomSheet(context, translate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark,
              color: Colors.grey[700],
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              translate('checkpoint', '분기점'),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more,
              color: Colors.grey[700],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckpointBottomSheet(BuildContext context, Function translate) {
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
                          translate,
                          index + 1,
                          index == 0, // 첫 번째만 저장된 상태로 표시
                        )),
                const SizedBox(height: 20),
                // 새 분기점 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Intent로 처리 예정
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(translate('save_checkpoint', '현재 상태 저장')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
    Function translate,
    int index,
    bool hasSave,
  ) {
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
                    '00:05 • 12개 완료',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasSave) ...[
            IconButton(
              onPressed: () {
                // TODO: Intent로 처리 예정
                Navigator.pop(context);
              },
              icon: const Icon(Icons.restore, size: 20),
              tooltip: translate('load_checkpoint', '불러오기'),
            ),
            IconButton(
              onPressed: () {
                // TODO: Intent로 처리 예정
              },
              icon: const Icon(Icons.delete, size: 20),
              tooltip: translate('delete_checkpoint', '삭제'),
            ),
          ] else ...[
            Text(
              translate('empty', '비어있음'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
