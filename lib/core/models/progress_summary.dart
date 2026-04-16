import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_summary.freezed.dart';
part 'progress_summary.g.dart';

@freezed
sealed class ProgressSummary with _$ProgressSummary {
  const factory ProgressSummary({
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
    @JsonKey(name: 'completed_subtopics') @Default(0) int completedSubtopics,
    @JsonKey(name: 'completed_topics') @Default(0) int completedTopics,
    @JsonKey(name: 'completed_chapters') @Default(0) int completedChapters,
  }) = _ProgressSummary;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) =>
      _$ProgressSummaryFromJson(json);
}
