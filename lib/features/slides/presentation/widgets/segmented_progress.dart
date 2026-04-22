import 'package:flutter/material.dart';

class SegmentedProgress extends StatelessWidget {
  final int total;
  final int current;
  final Set<int> completed;

  const SegmentedProgress({
    super.key,
    required this.total,
    required this.current,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: List.generate(total, (i) {
          final isDone = completed.contains(i) || i < current;
          final isCurrent = i == current;

          final color = isDone
              ? colors.primary
              : isCurrent
                  ? colors.primary.withAlpha(128)
                  : colors.onSurfaceVariant.withAlpha(64);

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}