import 'package:flutter/material.dart';
import 'package:nexus/core/routes/slides/slide_routes.dart';
import 'package:nexus/features/content/data/models/subtopic.dart';

class SubtopicCard extends StatelessWidget {
  final Subtopic subtopic;
  final int index;
  final bool isCompleted;
  const SubtopicCard({
    super.key,
    required this.subtopic,
    required this.index,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final laneColor = index.isEven
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    //  final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        SlideViewerRoute(
          subtopicId: subtopic.id,
          subtopicTitle: subtopic.title,
        ).push(context);
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: laneColor.withValues(alpha: 0.28)),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: laneColor.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: laneColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subtopic.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  context,
                  icon: Icons.whatshot_rounded,
                  label:
                      '+${subtopic.xpReward > 0 ? subtopic.xpReward : 12 + index} XP',
                  color: Colors.deepOrange,
                ),
                _chip(
                  context,
                  icon: Icons.schedule_rounded,
                  label: '${4 + (index % 3)} min',
                  color: laneColor,
                ),
                _chip(
                  context,
                  icon: Icons.star_rounded,
                  label: 'Challenge',
                  color: Colors.amber.shade800,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: isCompleted ? 1 : 0,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: laneColor.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? colors.tertiary : laneColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.replay_rounded
                            : Icons.play_arrow_rounded,
                        color: isCompleted
                            ? colors.onTertiary
                            : colors.onPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted ? 'Revise' : 'Start',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isCompleted
                              ? colors.onTertiary
                              : colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
