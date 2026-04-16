import 'package:interactive_learn/core/models/progress_summary.dart';
import 'package:interactive_learn/core/models/progress_update_result.dart';
import 'package:interactive_learn/core/models/completed_lesson.dart';
import 'package:interactive_learn/core/models/weekly_subject_progress.dart';
import 'package:interactive_learn/core/providers/auth_provider.dart';
import 'package:interactive_learn/core/services/progress_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_provider.g.dart';

@Riverpod(keepAlive: true)
FutureOr<ProgressSummary> progressSummary(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const ProgressSummary();
  return ProgressService.getMyProgressSummary();
}

@Riverpod(keepAlive: true)
FutureOr<Set<int>> completedChapterIds(Ref ref, int subjectId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ProgressService.fetchCompletedChapterIds(subjectId);
}

@Riverpod(keepAlive: true)
FutureOr<Set<int>> completedTopicIds(Ref ref, int chapterId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ProgressService.fetchCompletedTopicIds(chapterId);
}

@Riverpod(keepAlive: true)
FutureOr<Set<int>> completedSubtopicIds(Ref ref, int topicId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ProgressService.fetchCompletedSubtopicIds(topicId);
}

@Riverpod(keepAlive: true)
FutureOr<List<WeeklySubjectProgress>> weeklySubjectProgress(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ProgressService.fetchWeeklySubjectProgress();
}

@Riverpod(keepAlive: true)
FutureOr<List<CompletedLesson>> recentCompletedLessons(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ProgressService.fetchRecentCompletedLessons();
}

@Riverpod(keepAlive: true)
class ProgressActions extends _$ProgressActions {
  @override
  FutureOr<void> build() {}

  Future<ProgressUpdateResult> completeSubtopic(int subtopicId) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ProgressService.completeSubtopicAndAwardXp(subtopicId),
    );

    if (!ref.mounted) return const ProgressUpdateResult();

    state = result.whenData((_) {});

    ref.invalidate(progressSummaryProvider);
    ref.invalidate(completedSubtopicIdsProvider);
    ref.invalidate(completedTopicIdsProvider);
    ref.invalidate(completedChapterIdsProvider);

    return result.asData?.value ?? const ProgressUpdateResult();
  }
}
