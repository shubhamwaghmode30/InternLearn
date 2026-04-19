import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/providers/leaderboard_provider.dart';
import 'package:random_avatar/random_avatar.dart';

class LeaderboardScreen extends HookConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the leaderboard data state from our Riverpod provider
    final leaderboardState = ref.watch(leaderboardProvider);

    // Local state to hold the countdown string
    final timeRemaining = useState<String>('');

    // Hook to calculate and update the weekly countdown timer
    useEffect(() {
      void updateTime() {
        final now = DateTime.now();
        // Calculate days remaining until Sunday
        int daysUntilSunday = DateTime.sunday - now.weekday;
        
        // Target: Sunday at 11:59:59 PM
        final nextSunday = DateTime(
          now.year, now.month, now.day + daysUntilSunday, 23, 59, 59
        );

        final difference = nextSunday.difference(now);
        final days = difference.inDays;
        final hours = difference.inHours % 24;
        final minutes = difference.inMinutes % 60;

        timeRemaining.value = '${days}d ${hours}h ${minutes}m';
      }

      updateTime(); // Initial call
      // Update the timer UI every 60 seconds
      final timer = Timer.periodic(const Duration(minutes: 1), (_) => updateTime());
      return timer.cancel; // Cleanup on unmount
    }, []);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16), // Top padding for safety
            
            // 1. Gamified League Progression Badges 
            _buildLeagueBadgesRow(context),

            const SizedBox(height: 12), 

            // 2. The Stone League & Timer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Stone League', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14), 
                      const SizedBox(width: 4),
                      Text(
                        'Ends in ${timeRemaining.value}',
                        style: const TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.normal, 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. Main Leaderboard List
            Expanded(
              child: leaderboardState.when(
                data: (leaders) => ListView.builder(
                  itemCount: leaders.length,
                  itemBuilder: (context, index) {
                    final leader = leaders[index];
                    final isTopThree = leader.rank <= 3;
                    
                    // Flag to highlight the current user's row
                    final isMe = leader.name == 'Shubham Waghmode';

                    // Determine active zone for the current user
                    final isPromotion = leader.rank <= 10;
                    final isDemotion = leader.rank >= 34;

                    // Subtle zebra-striping for table readability
                    final isEven = index % 2 == 0;
                    final opacity = isEven ? 0.15 : 0.05;

                    Color zoneColor;
                    Color darkHighlightColor;
                    
                    // Assign colors based on bracket zones
                    if (isPromotion) {
                      zoneColor = Colors.green.withOpacity(opacity);
                      darkHighlightColor = Colors.green.shade700;
                    } else if (isDemotion) {
                      zoneColor = Colors.red.withOpacity(opacity);
                      darkHighlightColor = Colors.red.shade700;
                    } else {
                      zoneColor = Colors.blue.withOpacity(opacity); 
                      darkHighlightColor = Colors.blue.shade700;
                    }

                    // Build the individual user row
                    Widget leaderRow = Container(
                      color: isMe ? darkHighlightColor : zoneColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                      child: Row(
                        children: [
                          // Rank / Trophy
                          SizedBox(
                            width: 30,
                            child: Center(
                              child: isTopThree
                                  ? Icon(Icons.emoji_events, color: _getRankColor(leader.rank), size: 24) 
                                  : Text(
                                      '${leader.rank}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface, 
                                        fontSize: 14 
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Dynamically generated avatar based on username
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            child: ClipOval(
                              child: RandomAvatar(
                                leader.name,
                                width: 36,
                                height: 36,
                                trBackground: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Username
                          Expanded(
                            child: Text(
                              leader.name,
                              style: TextStyle(
                                fontWeight: isMe ? FontWeight.w900 : FontWeight.w600, 
                                fontSize: 14, 
                                color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),

                          // XP Score and Icon
                          Text(
                            '${leader.xp}',
                            style: TextStyle(
                              color: isMe ? Colors.white : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14, 
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.bolt, color: isMe ? Colors.white : Colors.amber, size: 18), 
                        ],
                      ),
                    );

                    // Inject visual dividers between zones
                    if (index == 10) {
                      return Column(
                        children: [
                          _buildContinuousZoneDivider(context, 'PROMOTION ZONE', Colors.green),
                          leaderRow,
                        ],
                      );
                    }

                    if (index == 33) {
                      return Column(
                        children: [
                          _buildContinuousZoneDivider(context, 'DANGER ZONE', Colors.red),
                          leaderRow,
                        ],
                      );
                    }

                    return leaderRow;
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Center(child: Text('Error loading leaderboard')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  /// Builds the horizontally scrolling list of league badges
  Widget _buildLeagueBadgesRow(BuildContext context) {
    return Container(
      height: 90, // Adjusted height to fit the new text perfectly
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildBadge(context, 'Wood', Colors.brown.shade400, isActive: false, isLocked: false),
          _buildBadge(context, 'Stone', Colors.grey.shade500, isActive: true, isLocked: false),
          _buildBadge(context, 'Bronze', const Color(0xFFC56C39), isActive: false, isLocked: true), // Deep richer bronze
          _buildBadge(context, 'Silver', const Color(0xFFC0C0C0), isActive: false, isLocked: true),
          _buildBadge(context, 'Gold', const Color(0xFFFFB800), isActive: false, isLocked: true),   // Warmer brighter gold
        ],
      ),
    );
  }

  /// Builds an individual league badge using the custom </> symbol
  Widget _buildBadge(BuildContext context, String name, Color baseColor, {required bool isActive, required bool isLocked}) {
    final displayColor = isLocked ? Colors.grey.withOpacity(0.3) : baseColor;

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // The main badge circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: displayColor.withOpacity(0.15),
                  border: isActive ? Border.all(color: displayColor, width: 3) : null,
                ),
                // The custom coding symbol inside the badge
                child: Center(
                  child: Text(
                    '</>',
                    style: TextStyle(
                      color: displayColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0, // Pulls the characters together slightly
                    ),
                  ),
                ),
              ),
              // Lock overlay for future leagues
              if (isLocked)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // League name
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Theme.of(context).colorScheme.onSurface : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Draws a continuous, full-width colored divider to separate bracket zones
  Widget _buildContinuousZoneDivider(BuildContext context, String label, Color color) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, 
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: color, thickness: 1.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: color, thickness: 1.5)),
        ],
      ),
    );
  }

  /// Maps a rank integer to a standard trophy color
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFB800); // Warmer, richer Gold
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFC56C39); // Deeper, more reddish Bronze
      default: return Colors.grey;
    }
  }
}