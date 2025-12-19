import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.canNavigate,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final bool canNavigate;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: canNavigate ? iconColor : iconColor.withValues(alpha: 0.3)),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }
}
