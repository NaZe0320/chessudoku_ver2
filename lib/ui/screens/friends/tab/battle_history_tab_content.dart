import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class BattleHistoryTabContent extends StatelessWidget {
  const BattleHistoryTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isWin = index % 3 != 2;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isWin ? Colors.green : Colors.red,
                child: Icon(
                  isWin ? Icons.check : Icons.close,
                  color: Colors.white,
                ),
              ),
              title: Text('vs 친구${index + 1}'),
              subtitle: Text(
                  '${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]} • ${isWin ? '승리' : '패배'}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isWin ? '+' : '-'}${10 + index * 2}점',
                    style: TextStyle(
                      color: isWin ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${5 + index * 3}분',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
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
