import 'package:flutter/material.dart';

class AppBarIconButton extends StatelessWidget {
  
  final IconData icon;
  final bool isScrolled;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry margin;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.isScrolled,
    required this.onPressed,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin,
      decoration: BoxDecoration(
        color: isScrolled ? Colors.transparent : Colors.white.withAlpha(52),
        borderRadius: BorderRadius.circular(24),
        shape: BoxShape.rectangle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8.0),
        iconSize: 24.0,
      ),
    );
  }
}