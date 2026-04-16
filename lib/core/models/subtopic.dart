import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtopic.freezed.dart';
part 'subtopic.g.dart';

@freezed
sealed class Subtopic with _$Subtopic {
  const factory Subtopic({
    required int id,
    required String title,
    @JsonKey(name: 'topic_id') required int topicId,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
    @JsonKey(name: 'order') int? order,
  }) = _Subtopic;

  factory Subtopic.fromJson(Map<String, dynamic> json) =>
      _$SubtopicFromJson(json);
}
