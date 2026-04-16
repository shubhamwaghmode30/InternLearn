import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_subject_progress.freezed.dart';
part 'weekly_subject_progress.g.dart';

@freezed
sealed class WeeklySubjectProgress with _$WeeklySubjectProgress {
  const factory WeeklySubjectProgress({
    @JsonKey(name: 'subject_id') required int subjectId,
    @JsonKey(name: 'subject_name') required String subjectName,
    @JsonKey(name: 'day_bucket') required DateTime dayBucket,
    @JsonKey(name: 'xp_earned') @Default(0) int xpEarned,
    @JsonKey(name: 'lesson_count') @Default(0) int lessonCount,
  }) = _WeeklySubjectProgress;

  factory WeeklySubjectProgress.fromJson(Map<String, dynamic> json) =>
      _$WeeklySubjectProgressFromJson(json);
}
