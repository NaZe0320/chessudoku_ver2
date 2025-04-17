import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double height;
  final TextStyle? titleStyle;

  const BaseAppBar({
    super.key,
    this.leading,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.height = kToolbarHeight,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 좌측 버튼
            if (leading != null)
              leading!
            else
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: foregroundColor ?? Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),

            // 타이틀
            Expanded(
              child: Text(
                title,
                style: titleStyle ??
                    TextStyle(
                      color: foregroundColor ?? Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            // 우측 액션 버튼들
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
