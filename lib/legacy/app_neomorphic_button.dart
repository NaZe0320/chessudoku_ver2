import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum NeomorphicButtonType {
  primary,
  secondary,
  accent,
  error,
}

enum NeomorphicButtonSize {
  small,
  medium,
  large,
}

/// 뉴모피즘 디자인 스타일의 버튼 컴포넌트
class AppNeomorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final NeomorphicButtonType type;
  final NeomorphicButtonSize size;
  final bool isDisabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final bool isActive;
  final String? tooltip;

  const AppNeomorphicButton({
    super.key,
    required this.text,
    this.onTap,
    this.type = NeomorphicButtonType.primary,
    this.size = NeomorphicButtonSize.medium,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 12.0,
    this.isActive = false,
    this.tooltip,
  });

  @override
  State<AppNeomorphicButton> createState() => _AppNeomorphicButtonState();
}

class _AppNeomorphicButtonState extends State<AppNeomorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final button = Opacity(
      opacity: widget.isDisabled ? 0.6 : 1.0,
      child: GestureDetector(
        onTapDown: widget.isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isDisabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: widget.isDisabled ? null : () => setState(() => _isPressed = false),
        onTap: widget.isDisabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: _getPadding(),
          decoration: BoxDecoration(
            color: _getBaseColor(),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.isActive ? _getTextColor().withAlpha(51) : AppColors2.neutral300,
              width: 1,
            ),
            boxShadow: _isPressed || widget.isActive
                ? null
                : [
                    BoxShadow(
                      color: AppColors2.neutral400.withAlpha(10),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.prefixIcon != null) ...[
                widget.prefixIcon!,
                if (widget.text.isNotEmpty) const SizedBox(width: 6),
              ],
              Text(
                widget.text,
                style: _getTextStyle(),
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: 6),
                if (widget.text.isNotEmpty) widget.suffixIcon!,
              ],
            ],
          ),
        ),
      ),
    );

    return widget.tooltip != null
        ? Tooltip(
            message: widget.tooltip!,
            child: button,
          )
        : button;
  }

  Color _getBaseColor() {
    if (widget.isActive) {
      switch (widget.type) {
        case NeomorphicButtonType.primary:
          return AppColors2.primary.withAlpha(13);
        case NeomorphicButtonType.secondary:
          return AppColors2.secondary.withAlpha(13);
        case NeomorphicButtonType.accent:
          return AppColors2.accent1.withAlpha(13);
        case NeomorphicButtonType.error:
          return AppColors2.error.withAlpha(13);
      }
    } else {
      return AppColors2.neutral200;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case NeomorphicButtonType.primary:
        return AppColors2.primary;
      case NeomorphicButtonType.secondary:
        return AppColors2.secondary;
      case NeomorphicButtonType.accent:
        return AppColors2.accent1;
      case NeomorphicButtonType.error:
        return AppColors2.error;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case NeomorphicButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
      case NeomorphicButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case NeomorphicButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  TextStyle _getTextStyle() {
    TextStyle style;
    switch (widget.size) {
      case NeomorphicButtonSize.small:
        style = AppTextStyles.buttonSmall;
        break;
      case NeomorphicButtonSize.medium:
        style = AppTextStyles.buttonMedium;
        break;
      case NeomorphicButtonSize.large:
        style = AppTextStyles.buttonLarge;
        break;
    }
    return style.copyWith(color: _getTextColor());
  }
}
