import 'package:nexus/features/slides/data/models/slide.dart';
import 'package:nexus/features/slides/data/models/slide_match.dart';
import 'package:nexus/features/slides/data/models/slide_mcq.dart';
import 'package:nexus/core/singleton.dart';

class SlideService {
  static Future<List<Slide>> getSlides(int subtopicId) async {
    try {
      final response = await supabase
          .from("slide")
          .select()
          .eq("subtopic_id", subtopicId);
      return response.map((json) => Slide.fromJson(json)).toList();
    } catch (e) {
      logger.e("Failed to fetch slides: $e");
      return [];
    }
  }

  static Future<List<SlideMcq>> getSlidesMCQ(int subtopicId) async {
    try {
      final response = await supabase
          .from("slide_mcq")
          .select()
          .eq("subtopic_id", subtopicId);
      return response.map((json) => SlideMcq.fromJson(json)).toList();
    } catch (e) {
      logger.e("Failed to fetch slides: $e");
      return [];
    }
  }

  static Future<List<SlideMatch>> getSlidesMatch(int subtopicId) async {
    try {
      final response = await supabase
          .from("slide_match")
          .select()
          .eq("subtopic_id", subtopicId);
      return response.map((json) => SlideMatch.fromJson(json)).toList();
    } catch (e) {
      logger.e("Failed to fetch slides: $e");
      return [];
    }
  }
}
