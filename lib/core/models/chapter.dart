import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter.freezed.dart';
part 'chapter.g.dart';

@freezed
sealed class Chapter with _$Chapter {
  const factory Chapter({
    int? id,
    @JsonKey(name: 'subject_id') required int subjectId,
    @JsonKey(name: 'chapter_number') required int chapterNumber,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
    required String name,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);
}
