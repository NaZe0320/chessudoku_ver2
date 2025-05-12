import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final ButtonType type;
  final ButtonSize size;
  final bool isDisabled;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(_getButtonBorderRadius()),
            splashColor: _getSplashColor(),
            highlightColor: _getHighlightColor(),
            child: Ink(
              decoration: BoxDecoration(
                color: _getButtonColor(),
                borderRadius: BorderRadius.circular(_getButtonBorderRadius()),
              ),
              child: Padding(
                padding: _getButtonPadding(),
                child: Row(
                  mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: _getTextStyle(),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      suffixIcon!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors2.primary;
      case ButtonType.secondary:
        return AppColors2.secondary;
      case ButtonType.success:
        return AppColors2.success;
      case ButtonType.warning:
        return AppColors2.warning;
      case ButtonType.error:
        return AppColors2.error;
      case ButtonType.info:
        return AppColors2.info;
    }
  }

  Color _getSplashColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors2.primaryDark;
      case ButtonType.secondary:
        return AppColors2.secondaryDark;
      case ButtonType.success:
        return Colors.green.shade700;
      case ButtonType.warning:
        return Colors.amber.shade700;
      case ButtonType.error:
        return Colors.red.shade700;
      case ButtonType.info:
        return Colors.blue.shade700;
    }
  }

  Color _getHighlightColor() {
    return _getSplashColor().withAlpha(30);
  }

  double _getButtonBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 8.0;
      case ButtonSize.medium:
        return 12.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  EdgeInsets _getButtonPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }
}
