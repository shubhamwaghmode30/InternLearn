import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_update_result.freezed.dart';
part 'progress_update_result.g.dart';

@freezed
sealed class ProgressUpdateResult with _$ProgressUpdateResult {
  const factory ProgressUpdateResult({
    @JsonKey(name: 'subtopic_completed') @Default(false) bool subtopicCompleted,
    @JsonKey(name: 'topic_completed') @Default(false) bool topicCompleted,
    @JsonKey(name: 'chapter_completed') @Default(false) bool chapterCompleted,
    @JsonKey(name: 'gained_xp') @Default(0) int gainedXp,
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
  }) = _ProgressUpdateResult;

  factory ProgressUpdateResult.fromJson(Map<String, dynamic> json) =>
      _$ProgressUpdateResultFromJson(json);
}
