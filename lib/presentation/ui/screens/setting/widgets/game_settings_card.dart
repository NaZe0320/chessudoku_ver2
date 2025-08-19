import 'package:chessudoku/presentation/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/providers.dart';

class GameSettingsCard extends HookConsumerWidget {
  const GameSettingsCard({
    super.key,
    required this.translate,
  });

  final String Function(String, [String?]) translate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameSettingsNotifierProvider);
    final notifier = ref.read(gameSettingsNotifierProvider.notifier);

    Widget buildSwitchRow({
      required IconData icon,
      required String title,
      required String onLabel,
      required String offLabel,
      required String pillOnLabel,
      required String pillOffLabel,
      required bool isOn,
      required VoidCallback onToggle,
    }) {
      return SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textWhite),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _OnOffLabel(isOn: isOn, onText: onLabel, offText: offLabel),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onToggle,
                child: _PillToggle(
                  isOn: isOn,
                  onLabel: pillOnLabel,
                  offLabel: pillOffLabel,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 같은 숫자 표시 토글
          SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_9_plus, color: AppColors.textWhite),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('highlight_same_numbers', '같은 숫자 표시'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _OnOffLabel(
                          isOn: settings.highlightSameNumbers,
                          onText: translate('display', '표시'),
                          offText: translate('hide', '표시 안함'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: notifier.toggleHighlightSameNumbers,
                    child: _PillToggle(
                      isOn: settings.highlightSameNumbers,
                      onLabel: translate('on', '켜짐'),
                      offLabel: translate('off', '꺼짐'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          buildSwitchRow(
            icon: Icons.select_all,
            title: translate('show_scope_on_select', '숫자/기물 선택 시 표시 범위'),
            onLabel: translate('on', '켜짐'),
            offLabel: translate('off', '꺼짐'),
            pillOnLabel: translate('on', '켜짐'),
            pillOffLabel: translate('off', '꺼짐'),
            isOn: settings.showScopeOnSelect,
            onToggle: notifier.toggleShowScopeOnSelect,
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          buildSwitchRow(
            icon: Icons.auto_fix_high_outlined,
            title: translate('auto_note_clear', '자동 메모 삭제'),
            onLabel: translate('on', '켜짐'),
            offLabel: translate('off', '꺼짐'),
            pillOnLabel: translate('on', '켜짐'),
            pillOffLabel: translate('off', '꺼짐'),
            isOn: settings.autoNoteClear,
            onToggle: notifier.toggleAutoNoteClear,
          ),
        ],
      ),
    );
  }
}

class _OnOffLabel extends StatelessWidget {
  const _OnOffLabel(
      {required this.isOn, required this.onText, required this.offText});
  final bool isOn;
  final String onText;
  final String offText;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isOn
                ? Colors.greenAccent.withValues(alpha: 0.25)
                : Colors.redAccent.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isOn
                  ? Colors.greenAccent.withValues(alpha: 0.6)
                  : Colors.redAccent.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            isOn ? onText : offText,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PillToggle extends StatelessWidget {
  const _PillToggle({
    required this.isOn,
    required this.onLabel,
    required this.offLabel,
  });

  final bool isOn;
  final String onLabel;
  final String offLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOn
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        isOn ? onLabel : offLabel,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
