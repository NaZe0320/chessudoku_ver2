import 'package:chessudoku/domain/enums/day_status.dart';

class DayProgress {
  final String label;
  final DayStatus status;

  const DayProgress({
    required this.label,
    required this.status,
  });
}