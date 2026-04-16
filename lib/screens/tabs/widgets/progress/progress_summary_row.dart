import 'package:flutter/material.dart';
import 'package:interactive_learn/core/models/progress_summary.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_stat_card.dart';

class ProgressSummaryRow extends StatelessWidget {
  final ProgressSummary summary;

  const ProgressSummaryRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final totalCompletions =
        summary.completedChapters + summary.completedTopics + summary.completedSubtopics;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProgressStatCard(
                title: 'Chapters',
                value: '${summary.completedChapters}',
                subtitle: 'Completed',
                icon: Icons.layers_rounded,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProgressStatCard(
                title: 'Topics',
                value: '${summary.completedTopics}',
                subtitle: 'Completed',
                icon: Icons.flag_circle_rounded,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ProgressStatCard(
                title: 'Subtopics',
                value: '${summary.completedSubtopics}',
                subtitle: 'Completed',
                icon: Icons.bolt_rounded,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProgressStatCard(
                title: 'Total',
                value: '$totalCompletions',
                subtitle: 'Milestones',
                icon: Icons.emoji_events_rounded,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}