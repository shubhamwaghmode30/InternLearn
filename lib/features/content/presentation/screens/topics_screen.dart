import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus/core/widgets/list_skeleton.dart';
import 'package:nexus/features/content/data/models/chapter.dart';
import 'package:nexus/features/content/data/models/subject.dart';
import 'package:nexus/features/content/data/riverpod/content_provider.dart';
import 'package:nexus/features/content/presentation/widgets/topics_header.dart';
import 'package:nexus/features/progress/data/riverpod/progress_provider.dart';
import 'package:nexus/features/content/presentation/widgets/topic_card.dart';

class TopicsScreen extends ConsumerWidget {
  final Subject subject;
  final Chapter chapter;
  const TopicsScreen({super.key, required this.subject, required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicProvider(chapter.id!));
    final completedAsync = ref.watch(completedTopicIdsProvider(chapter.id!));
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chapter.name),
            Text(
              '${subject.name} • Topic Run',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: topicsAsync.when(
        data: (topics) {
          if (topics.isEmpty) {
            return const Center(child: Text('No topics found.'));
          }
          return completedAsync.when(
            data: (completedIds) => ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: topics.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return TopicsHeader(
                    chapterName: chapter.name,
                    topicCount: topics.length,
                  );
                }

                final topicIndex = index - 1;
                final topic = topics[topicIndex];
                final shiftRight = topicIndex.isOdd;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(
                      left: shiftRight ? 28 : 0,
                      right: shiftRight ? 0 : 28,
                    ),
                    child: TopicCard(
                      subject: subject,
                      chapter: chapter,
                      topic: topic,
                      index: topicIndex,
                      isCompleted: completedIds.contains(topic.id),
                    ),
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
