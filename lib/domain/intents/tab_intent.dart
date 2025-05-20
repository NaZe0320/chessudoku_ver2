abstract class TabIntent {
}

class ChangeTabIntent extends TabIntent {
  final int index;

  ChangeTabIntent(this.index);
}
