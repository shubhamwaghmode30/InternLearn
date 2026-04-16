import 'package:interactive_learn/core/models/chapter.dart';
import 'package:interactive_learn/core/models/search_result_item.dart';
import 'package:interactive_learn/core/models/subject.dart';
import 'package:interactive_learn/core/models/subtopic.dart';
import 'package:interactive_learn/core/models/topic.dart';
import 'package:interactive_learn/core/singleton.dart';

class SearchService {
  static Future<List<SearchResultItem>> searchContent(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final escaped = q.replaceAll('%', r'\%').replaceAll('_', r'\_');
    final likePattern = '%$escaped%';

    try {
      final subjectsFuture = supabase
          .from('subject')
          .select('id,name,description')
          .or('name.ilike.$likePattern,description.ilike.$likePattern')
          .limit(8);

      final chaptersFuture = supabase
          .from('chapter')
          .select('id,subject_id,chapter_number,xp_reward,name,subject:subject_id(id,name,description)')
          .ilike('name', likePattern)
          .limit(8);

      final topicsFuture = supabase
          .from('topic')
          .select(
            'id,chapter_id,xp_reward,title,chapter:chapter_id(id,subject_id,chapter_number,xp_reward,name,subject:subject_id(id,name,description))',
          )
          .ilike('title', likePattern)
          .limit(8);

      final subtopicsFuture = supabase
          .from('subtopic')
          .select(
            'id,title,topic_id,xp_reward,order,topic:topic_id(id,chapter_id,xp_reward,title,chapter:chapter_id(id,subject_id,chapter_number,xp_reward,name,subject:subject_id(id,name,description)))',
          )
          .ilike('title', likePattern)
          .limit(8);

      final responses = await Future.wait([
        subjectsFuture,
        chaptersFuture,
        topicsFuture,
        subtopicsFuture,
      ]);

      final subjectRows = responses[0] as List<dynamic>;
      final chapterRows = responses[1] as List<dynamic>;
      final topicRows = responses[2] as List<dynamic>;
      final subtopicRows = responses[3] as List<dynamic>;

      final results = <SearchResultItem>[];

      for (final row in subjectRows) {
        final subject = Subject.fromJson(Map<String, dynamic>.from(row as Map));
        results.add(
          SearchResultItem(
            type: SearchEntityType.subject,
            title: subject.name,
            subtitle: subject.description?.trim().isNotEmpty == true
                ? subject.description!
                : 'Subject',
            subject: subject,
          ),
        );
      }

      for (final row in chapterRows) {
        final map = Map<String, dynamic>.from(row as Map);
        final subjectMap = Map<String, dynamic>.from(map['subject'] as Map);
        final subject = Subject.fromJson(subjectMap);
        final chapter = Chapter.fromJson(map);

        results.add(
          SearchResultItem(
            type: SearchEntityType.chapter,
            title: chapter.name,
            subtitle: 'Chapter • ${subject.name}',
            subject: subject,
            chapter: chapter,
          ),
        );
      }

      for (final row in topicRows) {
        final map = Map<String, dynamic>.from(row as Map);
        final chapterMap = Map<String, dynamic>.from(map['chapter'] as Map);
        final subjectMap = Map<String, dynamic>.from(chapterMap['subject'] as Map);
        final subject = Subject.fromJson(subjectMap);
        final chapter = Chapter.fromJson(chapterMap);
        final topic = Topic.fromJson(map);

        results.add(
          SearchResultItem(
            type: SearchEntityType.topic,
            title: topic.title,
            subtitle: 'Topic • ${subject.name} / ${chapter.name}',
            subject: subject,
            chapter: chapter,
            topic: topic,
          ),
        );
      }

      for (final row in subtopicRows) {
        final map = Map<String, dynamic>.from(row as Map);
        final topicMap = Map<String, dynamic>.from(map['topic'] as Map);
        final chapterMap = Map<String, dynamic>.from(topicMap['chapter'] as Map);
        final subjectMap = Map<String, dynamic>.from(chapterMap['subject'] as Map);

        final subject = Subject.fromJson(subjectMap);
        final chapter = Chapter.fromJson(chapterMap);
        final topic = Topic.fromJson(topicMap);
        final subtopic = Subtopic.fromJson(map);

        results.add(
          SearchResultItem(
            type: SearchEntityType.subtopic,
            title: subtopic.title,
            subtitle: 'Subtopic • ${subject.name} / ${chapter.name} / ${topic.title}',
            subject: subject,
            chapter: chapter,
            topic: topic,
            subtopic: subtopic,
          ),
        );
      }

      return results;
    } catch (e) {
      logger.e('Search failed', error: e);
      return [];
    }
  }
}