import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class FriendsListTabContent extends StatelessWidget {
  const FriendsListTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  '친${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('친구${index + 1}'),
              subtitle: Text('온라인 상태 • 레벨 ${15 + index}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // 대결 신청
                    },
                    icon: const Icon(Icons.sports_esports),
                    tooltip: '대결 신청',
                  ),
                  IconButton(
                    onPressed: () {
                      // 메시지 보내기
                    },
                    icon: const Icon(Icons.message),
                    tooltip: '메시지',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
