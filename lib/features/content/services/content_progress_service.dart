import 'package:nexus/core/singleton.dart';
import 'package:nexus/features/content/data/models/progress_update_result.dart';

class ContentProgressService {
  
  static Future<Set<int>> fetchCompletedChapterIds(int subjectId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return {};
      final response = await supabase
          .from('user_chapter_progress')
          .select('chapter_id, chapter!inner(subject_id)')
          .eq('user_id', userId)
          .eq('chapter.subject_id', subjectId);

      return response
          .map<int>((row) => row['chapter_id'] as int)
          .toSet();
    } catch (e) {
      logger.e('Failed to fetch completed chapter ids', error: e);
      return {};
    }
  }

  static Future<Set<int>> fetchCompletedTopicIds(int chapterId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return {};
      final response = await supabase
          .from('user_topic_progress')
          .select('topic_id, topic!inner(chapter_id)')
          .eq('user_id', userId)
          .eq('topic.chapter_id', chapterId);

      return response
          .map<int>((row) => row['topic_id'] as int)
          .toSet();
    } catch (e) {
      logger.e('Failed to fetch completed topic ids', error: e);
      return {};
    }
  }

  static Future<Set<int>> fetchCompletedSubtopicIds(int topicId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return {};
      final response = await supabase
          .from('user_subtopic_progress')
          .select('subtopic_id, subtopic!inner(topic_id)')
          .eq('user_id', userId)
          .eq('subtopic.topic_id', topicId);

      return response
          .map<int>((row) => row['subtopic_id'] as int)
          .toSet();
    } catch (e) {
      logger.e('Failed to fetch completed subtopic ids', error: e);
      return {};
    }
  }

  
  static Future<ProgressUpdateResult> completeSubtopicAndAwardXp(
    int subtopicId,
  ) async {
    try {
      final response = await supabase.rpc(
        'complete_subtopic_and_award_xp',
        params: {'p_subtopic_id': subtopicId},
      );
      if (response is List && response.isNotEmpty) {
        return ProgressUpdateResult.fromJson(
          response.first as Map<String, dynamic>,
        );
      }
      return const ProgressUpdateResult();
    } catch (e) {
      logger.e('Failed to complete subtopic and award xp', error: e);
      return const ProgressUpdateResult();
    }
  }

}