import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
sealed class Topic with _$Topic {
  const factory Topic({
    required int id,
    @JsonKey(name: 'chapter_id') required int chapterId,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
    required String title,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) =>
      _$TopicFromJson(json);
}