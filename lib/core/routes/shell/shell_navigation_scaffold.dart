import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus/core/routes/app_route_paths.dart';

class ShellNavigationScaffold extends StatelessWidget {
  const ShellNavigationScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _titles = [
    'Home',
    'Search',
    'Leaderboard',
    'Progress',
    'Profile',
  ];
  static const _paths = [
    AppRoutePaths.rootPath,
    AppRoutePaths.searchPath,
    AppRoutePaths.leaderboardPath,
    AppRoutePaths.progressPath,
    AppRoutePaths.profilePath,
  ];

  int _indexForLocation() {
    if (location == AppRoutePaths.rootPath) return 0;
    if (location.startsWith(AppRoutePaths.searchPath)) return 1;
    if (location.startsWith(AppRoutePaths.leaderboardPath)) return 2;
    if (location.startsWith(AppRoutePaths.progressPath)) return 3;
    if (location.startsWith(AppRoutePaths.profilePath)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexForLocation();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: child,
      bottomNavigationBar: ConvexAppBar(
        height: 60,
        top: -5,
        backgroundColor: colorScheme.surfaceContainer,
        activeColor: colorScheme.primary,
        color: colorScheme.onSurfaceVariant,
        initialActiveIndex: currentIndex,
        // curveSize: 10,
        onTap: (index) {
          final target = _paths[index];
          if (target != location) {
            context.go(target);
          }
        },
        style: TabStyle.reactCircle,
        items: const [
          TabItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            title: 'Home',
          ),
          TabItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            title: 'Search',
          ),
          TabItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            title: 'Rank',
          ),
          TabItem(
            icon: Icons.show_chart,
            activeIcon: Icons.stacked_line_chart,
            title: 'Progress',
          ),
          TabItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            title: 'Profile',
          ),
        ],
      ),
    );
  }
}
