import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus/core/widgets/list_skeleton.dart';
import 'package:nexus/features/content/data/models/chapter.dart';
import 'package:nexus/features/content/data/models/subject.dart';
import 'package:nexus/features/content/data/models/topic.dart';
import 'package:nexus/features/content/data/riverpod/content_provider.dart';
import 'package:nexus/features/progress/data/riverpod/progress_provider.dart';
import 'package:nexus/features/content/presentation/widgets/subtopic_card.dart';

class SubtopicsScreen extends ConsumerWidget {
  final Subject subject;
  final Chapter chapter;
  final Topic topic;
  const SubtopicsScreen({
    super.key,
    required this.subject,
    required this.chapter,
    required this.topic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtopicsAsync = ref.watch(subtopicProvider(topic.id));
    final completedAsync = ref.watch(completedSubtopicIdsProvider(topic.id));
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic.title),
            Text(
              '${subject.name} • ${chapter.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: subtopicsAsync.when(
        data: (subtopics) {
          if (subtopics.isEmpty) {
            return const Center(child: Text('No subtopics found.'));
          }
          // Sort by order if available
          final sorted = [...subtopics]
            ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
          return completedAsync.when(
            data: (completedIds) => ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: sorted.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SubtopicHeader(topicTitle: topic.title, count: sorted.length);
                }

                final subtopicIndex = index - 1;
                final subtopic = sorted[subtopicIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SubtopicCard(
                    subtopic: subtopic,
                    index: subtopicIndex,
                    isCompleted: completedIds.contains(subtopic.id),
                  ),
                );
              },
            ),
            loading: () => const ListSkeleton(),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const ListSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SubtopicHeader extends StatelessWidget {
  final String topicTitle;
  final int count;

  const _SubtopicHeader({required this.topicTitle, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.85),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'Challenge Track',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            topicTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count bite-sized lessons. Start from top and keep the streak alive.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

