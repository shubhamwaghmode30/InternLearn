import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus/features/slides/data/models/slide.dart';
import 'package:nexus/features/slides/data/models/slide_match.dart';
import 'package:nexus/features/slides/data/models/slide_mcq.dart';
import 'package:nexus/features/content/data/riverpod/progress_provider.dart';
import 'package:nexus/features/slides/data/riverpod/slide_provider.dart';
import 'package:nexus/features/slides/presentation/widgets/content_slide.dart';
import 'package:nexus/features/slides/presentation/widgets/match_slide.dart';
import 'package:nexus/features/slides/presentation/widgets/mcq_slide.dart';
import 'package:nexus/features/slides/presentation/widgets/segmented_progress.dart';

sealed class _SlideEntry {
  int get order;
}

final class _ContentEntry extends _SlideEntry {
  final Slide slide;
  _ContentEntry(this.slide);
  @override
  int get order => slide.order;
}

final class _McqEntry extends _SlideEntry {
  final SlideMcq mcq;
  _McqEntry(this.mcq);
  @override
  int get order => mcq.order;
}

final class _MatchEntry extends _SlideEntry {
  final SlideMatch match;
  _MatchEntry(this.match);
  @override
  int get order => match.order;
}

class SlideViewerBody extends HookConsumerWidget {
  final SlidesForSubtopic data;
  final String title;
  final int subtopicId;

  const SlideViewerBody({
    super.key,
    required this.data,
    required this.title,
    required this.subtopicId,
  });

  List<_SlideEntry> _buildEntries() {
    return <_SlideEntry>[
      ...data.slides.map(_ContentEntry.new),
      ...data.mcqSlides.map(_McqEntry.new),
      ...data.matchSlides.map(_MatchEntry.new),
    ]..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = useMemoized(_buildEntries, const []);
    final pageController = usePageController();
    final pageIndex = useState(0);
    final isFinishing = useState(false);
    final completedSet = useState(<int>{});

    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('No slides available for this subtopic yet.'),
            ],
          ),
        ),
      );
    }

    // Content slides are always unlocked; interactive slides need completion
    bool canProceed(int i) {
      if (i >= entries.length) return false;
      if (entries[i] is _ContentEntry) return true;
      return completedSet.value.contains(i);
    }

    void goTo(int newIndex) {
      pageIndex.value = newIndex;
      pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }

    void markComplete(int i) {
      completedSet.value = {...completedSet.value, i};
    }

    final isLast = pageIndex.value == entries.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: SegmentedProgress(
            total: entries.length,
            current: pageIndex.value,
            completed: completedSet.value,
          ),
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final entry = entries[i];
          if (entry is _ContentEntry) {

            return ContentSlideWidget(
              key: ValueKey('c_$i'),
              slide: entry.slide,
            );
          } else if (entry is _McqEntry) {

            return McqSlideWidget(
              key: ValueKey('mcq_$i'),
              mcq: entry.mcq,
              onCompleted: () => markComplete(i),
            );
          } else if (entry is _MatchEntry) {

            return MatchSlideWidget(
              key: ValueKey('match_$i'),
              match: entry.match,
              onCompleted: () => markComplete(i),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Back button
              if (pageIndex.value > 0)
                OutlinedButton.icon(
                  onPressed: () => goTo(pageIndex.value - 1),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                )
              else
                const SizedBox(width: 80),

              const Spacer(),

              Text(
                '${pageIndex.value + 1} / ${entries.length}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),

              const Spacer(),

              // Next / Finish button
              ElevatedButton.icon(
                onPressed: () {
                  bool canGo = canProceed(pageIndex.value);
                  if (!canGo) return;
                  if (isLast) {
                    if (isFinishing.value) return;
                    isFinishing.value = true;
                    // if ()
                    _completeSubtopic(
                      context,
                      ref,
                      () => isFinishing.value = false,
                    );
                  } else {
                    goTo(pageIndex.value + 1);
                  }
                },
                icon: Icon(
                  isLast ? Icons.emoji_events : Icons.arrow_forward,
                  size: 18,
                ),
                label: Text(
                  isLast
                      ? (isFinishing.value ? 'Saving...' : 'Finish')
                      : 'Next',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeSubtopic(
    BuildContext context,
    WidgetRef ref,
     VoidCallback onFinish,
  ) {
    ref
        .read(progressActionsProvider.notifier)
        .completeSubtopic(subtopicId)
        .then((result) {
          if (!context.mounted) return;

          final rewards = <String>[];
          if (result.subtopicCompleted) {
            rewards.add('Subtopic complete');
          }
          if (result.topicCompleted) {
            rewards.add('Topic unlocked');
          }
          if (result.chapterCompleted) {
            rewards.add('Chapter conquered');
          }

          final gained = result.gainedXp;
          final msg = gained > 0
              ? 'You earned +$gained XP${rewards.isNotEmpty ? ' • ${rewards.join(' • ')}' : ''}'
              : 'Already completed earlier. Keep practicing!';

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          
          context.pop();
        })
        .whenComplete(onFinish);
  }
}
