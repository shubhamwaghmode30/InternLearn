import 'package:freezed_annotation/freezed_annotation.dart';

part 'slide.freezed.dart';
part 'slide.g.dart';

@freezed
sealed class Slide with _$Slide {
  const factory Slide({
    int? id,

    @JsonKey(name: 'subtopic_id') required int subtopicId,

    required String title,

    @JsonKey(name: 'order') required int order,

    @JsonKey(name: 'body_md') @Default([]) List<String> bodyMd,

    @JsonKey(name: 'key_points') @Default([]) List<String> keyPoints,
  }) = _Slide;

  factory Slide.fromJson(Map<String, dynamic> json) => _$SlideFromJson(json);
}
