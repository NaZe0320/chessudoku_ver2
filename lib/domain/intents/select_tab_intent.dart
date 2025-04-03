import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/notifiers/navigation_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectTabIntent {
  final Ref ref;

  SelectTabIntent(this.ref);

  // 노티파이어에 대한 참조를 쉽게 얻기 위한 getter
  NavigationNotifier get _notifier =>
      ref.read(navigationNotifierProvider.notifier);

  void selectTab(int index) {
    _notifier.selectTab(index);
  }
}
