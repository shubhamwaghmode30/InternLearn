import 'package:nexus/features/content/data/models/progress_update_result.dart';
import 'package:nexus/features/content/services/content_progress_service.dart';
import 'package:nexus/features/progress/data/riverpod/progress_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_provider.g.dart';

@Riverpod(keepAlive: true)
class ProgressActions extends _$ProgressActions {
  @override
  FutureOr<void> build() {}

  Future<ProgressUpdateResult> completeSubtopic(int subtopicId) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ContentProgressService.completeSubtopicAndAwardXp(subtopicId),
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
