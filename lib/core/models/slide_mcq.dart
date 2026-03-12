import 'package:freezed_annotation/freezed_annotation.dart';

part 'slide_mcq.freezed.dart';
part 'slide_mcq.g.dart';

@freezed
sealed class SlideMcq with _$SlideMcq {
  const factory SlideMcq({
    required int id,

    @JsonKey(name: 'question_md') required String questionMd,

    @JsonKey(name: 'option_a') required String optionA,

    @JsonKey(name: 'option_b') required String optionB,

    @JsonKey(name: 'option_c') required String optionC,

    @JsonKey(name: 'option_d') required String optionD,

    @JsonKey(name: 'correct_option') required String correctOption,

    @JsonKey(name: 'explanation_md') required String explanationMd,

    @JsonKey(name: 'order') required int order,

    @JsonKey(name: 'subtopic_id') required int subtopicId,
  }) = _SlideMcq;

  factory SlideMcq.fromJson(Map<String, dynamic> json) =>
      _$SlideMcqFromJson(json);
}
