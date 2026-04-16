import 'package:flutter/material.dart';
import 'package:interactive_learn/core/models/progress_summary.dart';

class ProgressOverviewTab extends StatelessWidget {
  final ProgressSummary summary;

  const ProgressOverviewTab({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final totalCompletions =
        summary.completedChapters + summary.completedTopics + summary.completedSubtopics;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _OverviewTile(
          title: 'Consistency',
          subtitle: 'You have completed $totalCompletions milestones so far.',
          icon: Icons.shield_rounded,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _OverviewTile(
          title: 'Unlock Path',
          subtitle: 'Finish subtopics to auto-unlock topic and chapter rewards.',
          icon: Icons.lock_open_rounded,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _OverviewTile(
          title: 'XP Rhythm',
          subtitle: 'Every completed lesson adds to your total XP profile.',
          icon: Icons.bolt_rounded,
          color: Colors.deepOrange,
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _OverviewTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}