import 'package:flutter/material.dart';

class MatchSlideQuestionCard extends StatelessWidget {
  final ThemeData theme;
  final String question;

  const MatchSlideQuestionCard({
    super.key,
    required this.theme,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(question, style: theme.textTheme.titleMedium),
      ),
    );
  }
}
