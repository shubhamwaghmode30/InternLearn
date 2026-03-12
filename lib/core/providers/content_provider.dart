import 'package:interactive_learn/core/models/chapter.dart';
import 'package:interactive_learn/core/models/subject.dart';
import 'package:interactive_learn/core/models/subtopic.dart';
import 'package:interactive_learn/core/models/topic.dart';
import 'package:interactive_learn/core/services/chapter_service.dart';
import 'package:interactive_learn/core/services/subject_service.dart';
import 'package:interactive_learn/core/services/subtopic_service.dart';
import 'package:interactive_learn/core/services/topic_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_provider.g.dart';

@riverpod
FutureOr<List<Subject>> subject(Ref ref) {
  return SubjectService.fetchSubjects();
}

@riverpod
FutureOr<List<Chapter>> chapter(Ref ref, int subjectId) {
  return ChapterService.fetchChapters(subjectId);
}

@riverpod
FutureOr<List<Topic>> topic(Ref ref, int chapterId) {
  return TopicService.fetchTopics(chapterId);
}

@riverpod
FutureOr<List<Subtopic>> subtopic(Ref ref, int topicId) {
  return SubtopicService.fetchSubtopics(topicId);
}
