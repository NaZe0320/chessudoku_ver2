import 'package:chessudoku/ui/screens/main/widgets/day_progress_button.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class DailyChallengeCard extends StatelessWidget {
  final String title;
  final String streakText;
  final String statusText;
  final String messageText;
  final Function(String) onDayTap;

  const DailyChallengeCard({
    super.key,
    required this.title,
    required this.streakText,
    required this.statusText,
    required this.messageText,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: AppColors.textWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  streakText,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          // 요일별 진행 상황
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DayProgressButton(
                day: '월',
                isCompleted: true,
                onTap: () => onDayTap('월'),
              ),
              DayProgressButton(
                day: '화',
                isCompleted: true,
                onTap: () => onDayTap('화'),
              ),
              DayProgressButton(
                day: '수',
                isCompleted: false,
                onTap: () => onDayTap('수'),
              ),
              DayProgressButton(
                day: '목',
                isCompleted: true,
                onTap: () => onDayTap('목'),
              ),
              DayProgressButton(
                day: '금',
                isCompleted: false,
                onTap: () => onDayTap('금'),
              ),
              DayProgressButton(
                day: '토',
                isCompleted: false,
                onTap: () => onDayTap('토'),
              ),
              DayProgressButton(
                day: '일',
                isCompleted: false,
                onTap: () => onDayTap('일'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            messageText,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
