import 'package:flutter/material.dart';

class MatchSlideBadge extends StatelessWidget {
  final ThemeData theme;

  const MatchSlideBadge({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Match the Pairs',
        style: TextStyle(
          color: theme.colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
