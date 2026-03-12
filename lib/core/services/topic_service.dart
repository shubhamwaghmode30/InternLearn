import 'package:interactive_learn/core/models/topic.dart';
import 'package:interactive_learn/core/singleton.dart';

class TopicService {
  static Future<List<Topic>> fetchTopics(int chapterId) async {
    // Simulate network delay
    try {
      final response = await supabase
          .from("topic")
          .select()
          .eq("chapter_id", chapterId);
      return response.map((json) => Topic.fromJson(json)).toList();
    } catch (e) {
      logger.e("Failed to fetch topics: $e");
      return [];
    }
  }
}
