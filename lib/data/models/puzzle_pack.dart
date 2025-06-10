import 'dart:convert';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 퍼즐팩 정보를 담는 모델 클래스
class PuzzlePack {
  final String id;
  final String name;
  final int totalPuzzles;
  final Difficulty difficulty;
  final List<String> type;
  final bool isPremium;
  final String iconAsset;
  final int completedPuzzles;

  const PuzzlePack({
    required this.id,
    required this.name,
    required this.totalPuzzles,
    required this.difficulty,
    required this.type,
    this.isPremium = false,
    required this.iconAsset,
    this.completedPuzzles = 0,
  });

  /// 완료율 계산 (0.0 ~ 1.0)
  double get completionRate =>
      totalPuzzles > 0 ? completedPuzzles / totalPuzzles : 0.0;

  /// 진행 상태 텍스트
  String get progressText => '$completedPuzzles/$totalPuzzles';

  /// 완료 여부
  bool get isCompleted => completedPuzzles >= totalPuzzles;

  /// 데이터베이스에서 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'total_puzzles': totalPuzzles,
      'difficulty': difficulty.name,
      'types': jsonEncode(type),
      'is_premium': isPremium ? 1 : 0,
      'icon_asset': iconAsset,
      'completed_puzzles': completedPuzzles,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Map에서 PuzzlePack으로 변환
  factory PuzzlePack.fromMap(Map<String, dynamic> map) {
    return PuzzlePack(
      id: map['id'] as String,
      name: map['name'] as String,
      totalPuzzles: map['total_puzzles'] as int,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => Difficulty.easy,
      ),
      type: List<String>.from(jsonDecode(map['types'] as String)),
      isPremium: (map['is_premium'] as int) == 1,
      iconAsset: map['icon_asset'] as String,
      completedPuzzles: map['completed_puzzles'] as int,
    );
  }

  /// 진행률 업데이트를 위한 copyWith 메서드
  PuzzlePack copyWith({
    String? id,
    String? name,
    int? totalPuzzles,
    Difficulty? difficulty,
    List<String>? type,
    bool? isPremium,
    String? iconAsset,
    int? completedPuzzles,
  }) {
    return PuzzlePack(
      id: id ?? this.id,
      name: name ?? this.name,
      totalPuzzles: totalPuzzles ?? this.totalPuzzles,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      isPremium: isPremium ?? this.isPremium,
      iconAsset: iconAsset ?? this.iconAsset,
      completedPuzzles: completedPuzzles ?? this.completedPuzzles,
    );
  }
}
