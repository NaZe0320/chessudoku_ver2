enum Difficulty {
  easy('쉬움'),
  medium('보통'),
  hard('어려움'),
  expert('전문가');

  final String label;
  const Difficulty(this.label);

  /// 문자열에서 Difficulty 생성
  static Difficulty fromString(String difficultyStr) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.name == difficultyStr,
      orElse: () => Difficulty.easy,
    );
  }
}
