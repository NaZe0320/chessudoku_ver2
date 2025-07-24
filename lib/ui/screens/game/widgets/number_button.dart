import 'package:flutter/material.dart';

class NumberButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const NumberButton({
    super.key,
    required this.text,
    this.icon,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[100]
              : (isSelected ? Colors.blue[100] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDisabled
                ? Colors.grey[200]!
                : (isSelected ? Colors.blue[300]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: isDisabled
                      ? Colors.grey[400]
                      : (isSelected ? Colors.blue[700] : Colors.grey[700]),
                  size: 20,
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: isDisabled
                        ? Colors.grey[400]
                        : (isSelected ? Colors.blue[800] : Colors.grey[800]),
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
