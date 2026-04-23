import 'package:flutter/material.dart';

enum Behaviour { normal, solid }

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    this.icon,
    required this.label,
    required this.color,
    this.isSmall = false,
    this.behaviour = Behaviour.normal,
    this.textColor,
    this.bgColor,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final bool isSmall;
  final Behaviour behaviour;
  final Color? textColor;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isSmall
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor ?? color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor ?? color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
