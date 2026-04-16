import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/models/subject.dart';
import 'package:interactive_learn/core/providers/content_provider.dart';
import 'package:interactive_learn/screens/content/widgets/chapter_card.dart';

class ChaptersPage extends ConsumerWidget {
  final Subject subject;
  const ChaptersPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chapterProvider(subject.id));
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject.name),
            Text(
              'Chapters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(),
            ),
          ],
        ),
      ),
      body: chaptersAsync.when(
        data: (chapters) {
          final sortedChapters = [...chapters]..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
          if (chapters.isEmpty) {
            return const Center(child: Text('No chapters found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => ChapterCard(
              subject: subject,
              chapter: sortedChapters[index],
              index: index,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

