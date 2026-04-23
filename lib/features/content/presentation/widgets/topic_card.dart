import 'package:flutter/material.dart';
import 'package:nexus/core/routes/app_routes.dart';
import 'package:nexus/features/content/data/models/chapter.dart';
import 'package:nexus/features/content/data/models/subject.dart';
import 'package:nexus/features/content/data/models/topic.dart';

class TopicCard extends StatelessWidget {
  final Subject subject;
  final Chapter chapter;
  final Topic topic;
  final int index;
  final bool isCompleted;
  const TopicCard({
    super.key,
    required this.subject,
    required this.chapter,
    required this.topic,
    required this.index,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = index.isOdd
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    return  InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => SubtopicsRoute(
          $extra: SubtopicsNavData(
            subject: subject,
            chapter: chapter,
            topic: topic,
          ),
        ).push(context),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: accent.withValues(alpha: 0.15),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Mission ${index + 1}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                topic.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.military_tech_rounded,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text('Badge Reward', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  Icon(Icons.bolt, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 2),
                  Text(
                    '+${topic.xpReward > 0 ? topic.xpReward : 20 + (index * 3)} XP',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
