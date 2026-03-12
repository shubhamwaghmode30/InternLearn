import 'package:interactive_learn/core/models/subject.dart';
import 'package:interactive_learn/core/singleton.dart';

class SubjectService {
  static Future<List<Subject>> fetchSubjects() async {
    // Simulate network delay
    try {
      final response = await supabase.from("subject").select();
      return response.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      logger.e("Failed to fetch subjects: $e");
      return [];
    }
  }
}
