import 'package:interactive_learn/core/models/chapter.dart';
import 'package:interactive_learn/core/models/subject.dart';
import 'package:interactive_learn/core/models/subtopic.dart';
import 'package:interactive_learn/core/models/topic.dart';

enum SearchEntityType { subject, chapter, topic, subtopic }

class SearchResultItem {
  final SearchEntityType type;
  final String title;
  final String subtitle;
  final Subject subject;
  final Chapter? chapter;
  final Topic? topic;
  final Subtopic? subtopic;

  const SearchResultItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.subject,
    this.chapter,
    this.topic,
    this.subtopic,
  });
}