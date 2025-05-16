import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 게임 이어하기 선택 다이얼로그
///
/// 저장된 게임이 있을 때 표시되며, 이어하기 또는 새로 시작 중 선택할 수 있습니다.
class ContinueGameDialog extends StatelessWidget {
  const ContinueGameDialog({
    super.key,
    required this.difficulty,
  });

  /// 선택한 게임 난이도
  final Difficulty difficulty;

  /// 다이얼로그 표시 및 결과 반환
  ///
  /// [context]: 빌드 컨텍스트
  /// [difficulty]: 선택한 게임 난이도
  ///
  /// 반환값:
  /// - true: 이어하기 선택
  /// - false: 새로 시작 선택
  /// - null: 취소됨
  static Future<bool?> show(BuildContext context, Difficulty difficulty) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ContinueGameDialog(difficulty: difficulty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('저장된 게임 발견'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${difficulty.label} 난이도의 저장된 게임이 있습니다.'),
          const SizedBox(height: 8),
          const Text('이어서 진행하시겠습니까?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            '새로 시작',
            style: TextStyle(color: AppColors2.primary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors2.primary,
            foregroundColor: AppColors2.neutral100,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('이어하기'),
        ),
      ],
    );
  }
}
