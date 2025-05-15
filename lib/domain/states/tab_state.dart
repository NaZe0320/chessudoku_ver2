class TabState {
  final int selectedIndex;

  TabState({this.selectedIndex = 0});

  // 새 상태 반환 (불변성 유지)
  TabState copyWith({int? selectedIndex}) {
    return TabState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

