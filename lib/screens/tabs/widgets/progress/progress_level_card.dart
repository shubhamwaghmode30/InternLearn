import 'package:flutter/material.dart';

class ProgressLevelCard extends StatelessWidget {
  final int totalXp;

  const ProgressLevelCard({super.key, required this.totalXp});

  @override
  Widget build(BuildContext context) {
    final level = (totalXp ~/ 100) + 1;
    final progressInLevel = (totalXp % 100) / 100;
    final nextLevelXp = ((level * 100) - totalXp).clamp(0, 1000);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level $level',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressInLevel,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          Text(
            '$nextLevelXp XP to next level',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}