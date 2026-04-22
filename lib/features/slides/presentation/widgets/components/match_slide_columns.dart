import 'package:flutter/material.dart';
import 'package:nexus/features/slides/data/models/slide_match.dart';

class MatchSlideColumns extends StatelessWidget {
  final ThemeData theme;
  final List<MatchItem> leftItems;
  final List<MatchItem> rightItems;
  final Map<String, String> matchedPairs;
  final String? selectedLeftId;
  final (String, String)? wrongPair;
  final Color Function(String leftId) leftBg;
  final Color Function(String leftId) leftBorder;
  final Color Function(String rightId) rightBg;
  final Color Function(String rightId) rightBorder;
  final void Function(String leftId) onLeftTap;
  final void Function(String rightId) onRightTap;

  const MatchSlideColumns({
    super.key,
    required this.theme,
    required this.leftItems,
    required this.rightItems,
    required this.matchedPairs,
    required this.selectedLeftId,
    required this.wrongPair,
    required this.leftBg,
    required this.leftBorder,
    required this.rightBg,
    required this.rightBorder,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: leftItems.map((item) {
                final isMatched = matchedPairs.containsKey(item.id);
                return _LeftMatchCard(
                  theme: theme,
                  text: item.text,
                  isMatched: isMatched,
                  isSelected: selectedLeftId == item.id,
                  backgroundColor: leftBg(item.id),
                  borderColor: leftBorder(item.id),
                  onTap: () => onLeftTap(item.id),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rightItems.map((item) {
                final isMatched = matchedPairs.values.contains(item.id);
                return _RightMatchCard(
                  theme: theme,
                  text: item.text,
                  isMatched: isMatched,
                  backgroundColor: rightBg(item.id),
                  borderColor: rightBorder(item.id),
                  onTap: isMatched ? null : () => onRightTap(item.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftMatchCard extends StatelessWidget {
  final ThemeData theme;
  final String text;
  final bool isMatched;
  final bool isSelected;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _LeftMatchCard({
    required this.theme,
    required this.text,
    required this.isMatched,
    required this.isSelected,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isMatched ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (isMatched)
              const Icon(Icons.check_circle, size: 16, color: Colors.green),
            if (isSelected)
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _RightMatchCard extends StatelessWidget {
  final ThemeData theme;
  final String text;
  final bool isMatched;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const _RightMatchCard({
    required this.theme,
    required this.text,
    required this.isMatched,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            if (isMatched)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check_circle, size: 16, color: Colors.green),
              ),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isMatched ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
