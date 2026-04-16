import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/providers/progress_provider.dart';
import 'package:interactive_learn/core/widgets/loading_skeletons.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_completed_lessons_tab.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_header.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_level_card.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_overview_tab.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_summary_row.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_weekly_tab.dart';

class ProgressScreen extends HookConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);
    final weeklyAsync = ref.watch(weeklySubjectProgressProvider);
    final lessonsAsync = ref.watch(recentCompletedLessonsProvider);
    final tabController = useTabController(initialLength: 3);

    return Scaffold(
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const ProgressSkeleton(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (summary) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ProgressHeader(totalXp: summary.totalXp),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: ProgressSummaryRow(summary: summary),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProgressLevelCard(totalXp: summary.totalXp),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarHeaderDelegate(
                    TabBar(
                      controller: tabController,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Weekly Charts'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: tabController,
                children: [
                  ProgressOverviewTab(summary: summary),
                  weeklyAsync.when(
                    loading: () => const AppListSkeleton(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (weeklyData) => ProgressWeeklyTab(data: weeklyData),
                  ),
                  lessonsAsync.when(
                    loading: () => const AppListSkeleton(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (lessons) => ProgressCompletedLessonsTab(lessons: lessons),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}
