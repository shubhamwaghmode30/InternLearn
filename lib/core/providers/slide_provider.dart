import 'package:interactive_learn/core/models/slide.dart';
import 'package:interactive_learn/core/models/slide_match.dart';
import 'package:interactive_learn/core/models/slide_mcq.dart';
import 'package:interactive_learn/core/services/slide_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SlidesForSubtopic {
  final int subtopicId;
  final List<Slide> slides;
  final List<SlideMcq> mcqSlides;
  final List<SlideMatch> matchSlides;
  const SlidesForSubtopic({
    required this.subtopicId,
    required this.slides,
    required this.mcqSlides,
    required this.matchSlides,
  });
}

@riverpod
FutureOr<SlidesForSubtopic> slides(Ref ref, int subtopicId) async {
  try {
    final slideResponse = await SlideService.getSlides(subtopicId);
    final slideMcqResponse = await SlideService.getSlidesMCQ(subtopicId);
    final slideMatchResponse = await SlideService.getSlidesMatch(subtopicId);

    return SlidesForSubtopic(
      subtopicId: subtopicId,
      slides: slideResponse,
      mcqSlides: slideMcqResponse,
      matchSlides: slideMatchResponse,
    );
  } catch (e) {
    throw Exception('Failed to fetch slides: $e');
  }
}
