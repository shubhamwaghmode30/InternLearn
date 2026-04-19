import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:interactive_learn/screens/tabs/home_screen.dart';
import 'package:interactive_learn/screens/tabs/profile_screen.dart';
import 'package:interactive_learn/screens/tabs/search_screen.dart';
import 'package:interactive_learn/screens/tabs/progress_screen.dart';
import 'package:interactive_learn/screens/tabs/leaderboard_screen.dart'; // 1. Imported your new screen

class TabWidgetTree extends HookWidget {
  const TabWidgetTree({super.key});

  // 2. Added the screen to the pages list
  static const _pages = [
    HomeScreen(),
    SearchScreen(),
    LeaderboardScreen(), // Leaderboard placed in the middle
    ProgressScreen(),
    ProfileScreen(),     // Profile moved to the end
  ];

  // 3. Added the title to match the pages
  static const _titles = ['Home', 'Search', 'Leaderboard', 'Progress', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    // Access the current theme for consistency
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex.value]),
        // Ensuring AppBar matches M3 surface style
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _pages[selectedIndex.value],
      bottomNavigationBar: ConvexAppBar(
        height: 60,
        top: -10,

        backgroundColor: colorScheme.surfaceContainer,
        activeColor: colorScheme.primary,
        color: colorScheme.onSurfaceVariant,

        initialActiveIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,

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
          TabItem( // 4. Added the Trophy icon for the Leaderboard
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            title: 'Leaderboard',
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