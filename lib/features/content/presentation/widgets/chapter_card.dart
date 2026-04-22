import 'package:flutter/material.dart';
import 'package:nexus/core/routes/app_routes.dart';
import 'package:nexus/features/content/data/models/chapter.dart';
import 'package:nexus/features/content/data/models/subject.dart';

class ChapterCard extends StatelessWidget {
  final Subject subject;
  final Chapter chapter;
  final int index;
  final bool isCompleted;
  const ChapterCard({
    super.key,
    required this.subject,
    required this.chapter,
    required this.index,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOdd = index.isOdd;
    final badgeColor = isOdd
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;
    final earnedXp = chapter.xpReward > 0 ? chapter.xpReward : 30 + (index * 5);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => TopicsRoute(
        $extra: TopicsNavData(subject: subject, chapter: chapter),
      ).push(context),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              badgeColor.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    chapter.chapterNumber.toString(),
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Level ${index + 1}',
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              'Completed',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (isCompleted) const SizedBox(width: 8),
                        Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+$earnedXp XP',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chapter.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Chapter conquered. You unlocked the reward XP.'
                          : 'Complete this chapter to unlock the next quest path.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.arrow_circle_right_rounded,
                color: isCompleted ? Colors.green : badgeColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
