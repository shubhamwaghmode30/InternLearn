import 'package:freezed_annotation/freezed_annotation.dart';

part 'slide_match.freezed.dart';
part 'slide_match.g.dart';

@freezed
sealed class MatchPair with _$MatchPair {
  const factory MatchPair({required String leftId, required String rightId}) =
      _MatchPair;

  factory MatchPair.fromJson(Map<String, dynamic> json) =>
      _$MatchPairFromJson(json);
}

@freezed
sealed class MatchItem with _$MatchItem {
  const factory MatchItem({required String id, required String text}) =
      _MatchItem;

  factory MatchItem.fromJson(Map<String, dynamic> json) =>
      _$MatchItemFromJson(json);
}

@freezed
sealed class SlideMatch with _$SlideMatch {
  const factory SlideMatch({
    int? id,

    required String question,

    @JsonKey(name: 'left_items') required List<MatchItem> leftItems,

    @JsonKey(name: 'right_items') required List<MatchItem> rightItems,

    @JsonKey(name: 'correct_pairs') required List<MatchPair> correctPairs,

    @JsonKey(name: 'explanation_md') required String explanationMd,

    @JsonKey(name: 'order') required int order,

    @JsonKey(name: 'subtopic_id') required int subtopicId,
  }) = _SlideMatch;

  factory SlideMatch.fromJson(Map<String, dynamic> json) =>
      _$SlideMatchFromJson(json);
}
