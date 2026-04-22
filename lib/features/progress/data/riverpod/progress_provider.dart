import 'package:nexus/features/progress/data/models/progress_summary.dart';
import 'package:nexus/features/progress/data/models/completed_lesson.dart';
import 'package:nexus/features/progress/data/models/weekly_subject_progress.dart';
import 'package:nexus/features/auth/data/riverpod/auth_provider.dart';
import 'package:nexus/features/progress/service/progress_display_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_provider.g.dart';

@Riverpod(keepAlive: true)
FutureOr<ProgressSummary> progressSummary(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const ProgressSummary();
  return ProgressDisplayService.getMyProgressSummary();
}

@Riverpod(keepAlive: true)
FutureOr<Set<int>> completedChapterIds(Ref ref, int subjectId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ProgressDisplayService.fetchCompletedChapterIds(subjectId);
}

@Riverpod(keepAlive: true)
FutureOr<Set<int>> completedTopicIds(Ref ref, int chapterId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ProgressDisplayService.fetchCompletedTopicIds(chapterId);
}

@Riverpod(keepAlive: true)
FutureOr<Set<int>> completedSubtopicIds(Ref ref, int topicId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ProgressDisplayService.fetchCompletedSubtopicIds(topicId);
}

@Riverpod(keepAlive: true)
FutureOr<List<WeeklySubjectProgress>> weeklySubjectProgress(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ProgressDisplayService.fetchWeeklySubjectProgress();
}

@Riverpod(keepAlive: true)
FutureOr<List<CompletedLesson>> recentCompletedLessons(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ProgressDisplayService.fetchRecentCompletedLessons();
}

