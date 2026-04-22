import 'package:flutter/material.dart';

class MatchSlideHintText extends StatelessWidget {
  final ThemeData theme;
  final bool hasSelectedLeft;

  const MatchSlideHintText({
    super.key,
    required this.theme,
    required this.hasSelectedLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      hasSelectedLeft
          ? 'Now tap the matching item on the right →'
          : 'Tap a left item to select it, then tap its match.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: hasSelectedLeft ? theme.colorScheme.primary : Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
