import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus/core/widgets/list_skeleton.dart';
import 'package:nexus/features/content/data/models/subject.dart';
import 'package:nexus/features/content/data/riverpod/content_provider.dart';
import 'package:nexus/features/content/presentation/widgets/journey_header.dart';
import 'package:nexus/features/progress/data/riverpod/progress_provider.dart';
import 'package:nexus/features/content/presentation/widgets/chapter_card.dart';

class ChaptersPage extends ConsumerWidget {
  final Subject subject;
  const ChaptersPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chapterProvider(subject.id));
    final completedAsync = ref.watch(completedChapterIdsProvider(subject.id));
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject.name),
            Text(
              'Chapter Journey',
              style: Theme.of(
                context,
              ).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          final sortedChapters = [...chapters]
            ..sort((a, b) {
              final aNumber = a.chapterNumber;
              final bNumber = b.chapterNumber;
              return aNumber.compareTo(bNumber);
            });
          if (chapters.isEmpty) {
            return const Center(child: Text('No chapters found.'));
          }
          return completedAsync.when(
            data: (completedIds) => ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: sortedChapters.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return JourneyHeader(
                    subjectName: subject.name,
                    chapterCount: sortedChapters.length,
                  );
                }

                final chapterIndex = index - 1;
                final chapter = sortedChapters[chapterIndex];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ChapterCard(
                    subject: subject,
                    chapter: chapter,
                    index: chapterIndex,
                    isCompleted: completedIds.contains(chapter.id),
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
