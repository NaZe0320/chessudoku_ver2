import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class GameSettingsCard extends HookWidget {
  const GameSettingsCard({
    super.key,
    required this.translate,
  });

  final String Function(String, [String?]) translate;

  @override
  Widget build(BuildContext context) {
    final showScope = useState<bool>(true);
    final autoNoteClear = useState<bool>(true);

    Widget buildSwitchRow({
      required IconData icon,
      required String title,
      required String onLabel,
      required String offLabel,
      required String pillOnLabel,
      required String pillOffLabel,
      required ValueNotifier<bool> controller,
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
                    _OnOffLabel(
                        isOn: controller.value,
                        onText: onLabel,
                        offText: offLabel),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => controller.value = !controller.value,
                child: _PillToggle(
                  isOn: controller.value,
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
          buildSwitchRow(
            icon: Icons.select_all,
            title: translate('show_scope_on_select', '숫자/기물 선택 시 표시 범위'),
            onLabel: translate('display', '표시'),
            offLabel: translate('hide', '표시 안함'),
            pillOnLabel: translate('display', '표시'),
            pillOffLabel: translate('hide', '표시 안함'),
            controller: showScope,
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          buildSwitchRow(
            icon: Icons.auto_fix_high_outlined,
            title: translate('auto_note_clear', '자동 메모 삭제'),
            onLabel: translate('auto_delete', '자동 삭제'),
            offLabel: translate('no_auto_delete', '자동 삭제 안함'),
            pillOnLabel: translate('on', '켜짐'),
            pillOffLabel: translate('off', '꺼짐'),
            controller: autoNoteClear,
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
