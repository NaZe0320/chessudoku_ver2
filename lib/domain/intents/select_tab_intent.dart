import 'package:chessudoku/core/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectTabIntent {
  final int index;
  final WidgetRef ref;

  SelectTabIntent(this.ref, this.index);

  void execute() {
    ref.read(navigationProvider.notifier).selectTab(index);
  }
}
