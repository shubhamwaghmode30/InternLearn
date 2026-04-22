import 'package:nexus/features/progress/data/models/progress_summary.dart';
import 'package:nexus/features/progress/data/models/completed_lesson.dart';
import 'package:nexus/features/progress/data/models/weekly_subject_progress.dart';
import 'package:nexus/core/singleton.dart';

class ProgressDisplayService {
  static Future<ProgressSummary> getMyProgressSummary() async {
    try {
      if (supabase.auth.currentUser == null) return const ProgressSummary();
      final response = await supabase.rpc('get_my_progress_summary');
      if (response is List && response.isNotEmpty) {
        return ProgressSummary.fromJson(response.first as Map<String, dynamic>);
      }
      return const ProgressSummary();
    } catch (e) {
      logger.e('Failed to fetch progress summary', error: e);
      return const ProgressSummary();
    }
  }

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

  static Future<List<WeeklySubjectProgress>> fetchWeeklySubjectProgress() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase.rpc('get_weekly_subject_progress');
      if (response is List) {
        return response
            .map((row) => WeeklySubjectProgress.fromJson(
                  Map<String, dynamic>.from(row as Map),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      logger.e('Failed to fetch weekly subject progress', error: e);
      return [];
    }
  }

  static Future<List<CompletedLesson>> fetchRecentCompletedLessons() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase.rpc('get_recent_completed_lessons');
      if (response is List) {
        return response
            .map((row) => CompletedLesson.fromJson(
                  Map<String, dynamic>.from(row as Map),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      logger.e('Failed to fetch recent completed lessons', error: e);
      return [];
    }
  }
}
