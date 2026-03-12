import 'package:interactive_learn/core/models/chapter.dart';
import 'package:interactive_learn/core/singleton.dart';

class ChapterService {
  static Future<List<Chapter>> fetchChapters(int subjectId) async {
    // Simulate network delay
    try {
      final response = await supabase
          .from("chapter")
          .select()
          .eq("subject_id", subjectId);
      return response.map((json) => Chapter.fromJson(json)).toList();
    } catch (e) {
      logger.e("Failed to fetch chapters: $e");
      return [];
    }
  }
}