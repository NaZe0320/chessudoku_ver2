import 'package:chessudoku/domain/notifiers/filter_notifier.dart';
import 'package:chessudoku/domain/states/filter_state.dart';
import 'package:chessudoku/domain/intents/filter_intent.dart';
import 'package:chessudoku/ui/common/widgets/filter_chip/filter_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterChipGroup<T> extends ConsumerWidget {
  final StateNotifierProvider<FilterNotifier<T>, FilterState<T>> provider;
  final EdgeInsets? padding;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const FilterChipGroup({
    super.key,
    required this.provider,
    this.padding,
    this.alignment = WrapAlignment.start,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(provider);
    final filterNotifier = ref.read(provider.notifier);

    if (filterState.error != null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '필터 로드 중 오류가 발생했습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              filterState.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[700],
                  ),
            ),
          ],
        ),
      );
    }

    if (filterState.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final displayOptions = filterState.allOptionsWithAll;

    if (displayOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            ...displayOptions
                .map((option) => Padding(
                      padding: EdgeInsets.only(
                        right: spacing,
                      ),
                      child: FilterChipWidget(
                          option: option,
                          onTap: () => filterNotifier.handleIntent(
                              SelectFilterIntent(optionId: option.id))),
                    ))
                .toList(),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
