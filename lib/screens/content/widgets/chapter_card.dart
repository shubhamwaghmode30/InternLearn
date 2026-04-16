import 'package:flutter/material.dart';
import 'package:interactive_learn/core/models/chapter.dart';
import 'package:interactive_learn/core/models/subject.dart';
import 'package:interactive_learn/screens/content/topics_screen.dart';

class ChapterCard extends StatelessWidget {
  final Subject subject;
  final Chapter chapter;
  final int index;
  const ChapterCard({
    super.key,
    required this.subject,
    required this.chapter,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            chapter.chapterNumber.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          chapter.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Chapter ${chapter.chapterNumber}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TopicsScreen(subject: subject, chapter: chapter),
          ),
        ),
      ),
    );
  }
}
