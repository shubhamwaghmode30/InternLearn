import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus/core/widgets/list_skeleton.dart';
import 'package:nexus/features/content/data/models/subject.dart';
import 'package:nexus/features/content/data/riverpod/content_provider.dart';
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
                  return _JourneyHeader(
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

class _JourneyHeader extends StatelessWidget {
  final String subjectName;
  final int chapterCount;

  const _JourneyHeader({required this.subjectName, required this.chapterCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.95),
            theme.colorScheme.primary.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Quest Map',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subjectName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$chapterCount chapters to conquer. Clear each level to unlock deeper concepts.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
