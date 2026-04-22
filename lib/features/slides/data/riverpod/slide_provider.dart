import 'package:nexus/features/slides/data/models/slide.dart';
import 'package:nexus/features/slides/data/models/slide_match.dart';
import 'package:nexus/features/slides/data/models/slide_mcq.dart';
import 'package:nexus/features/slides/services/slide_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'slide_provider.g.dart';

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
