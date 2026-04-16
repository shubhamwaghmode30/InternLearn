import 'package:freezed_annotation/freezed_annotation.dart';

part 'completed_lesson.freezed.dart';
part 'completed_lesson.g.dart';

enum LessonType { chapter, topic, subtopic }

@freezed
sealed class CompletedLesson with _$CompletedLesson {
  const factory CompletedLesson({
    @JsonKey(name: 'lesson_type') required String lessonType,
    @JsonKey(name: 'subject_name') required String subjectName,
    @JsonKey(name: 'chapter_name') required String chapterName,
    @JsonKey(name: 'topic_name') required String topicName,
    @JsonKey(name: 'lesson_title') required String lessonTitle,
    @JsonKey(name: 'xp_earned') @Default(0) int xpEarned,
    @JsonKey(name: 'completed_at') required DateTime completedAt,
  }) = _CompletedLesson;

  factory CompletedLesson.fromJson(Map<String, dynamic> json) =>
      _$CompletedLessonFromJson(json);
}
