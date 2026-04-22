import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:nexus/features/slides/data/models/slide_mcq.dart';

class McqSlideWidget extends HookWidget {
  final SlideMcq mcq;
  final VoidCallback onCompleted;

  const McqSlideWidget({
    super.key,
    required this.mcq,
    required this.onCompleted,
  });

  static const _optionKeys = ['a', 'b', 'c', 'd'];
  static const _optionLabels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final selected = useState<String?>(null);
    final hasAnswered = useState(false);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final options = [mcq.optionA, mcq.optionB, mcq.optionC, mcq.optionD];

    void selectOption(String key) {
      if (hasAnswered.value) return;
      selected.value = key;
      hasAnswered.value = true;
      onCompleted();
    }

    Color cardColor(String key) {
      if (!hasAnswered.value) return colors.surface;
      if (key == mcq.correctOption) return colors.tertiaryContainer;
      if (key == selected.value) return colors.errorContainer;
      return colors.surface;
    }

    Color borderColor(String key) {
      if (!hasAnswered.value) {
        return selected.value == key
            ? colors.primary
            : colors.outlineVariant;
      }
      if (key == mcq.correctOption) return colors.tertiary;
      if (key == selected.value) return colors.error;
      return colors.outlineVariant;
    }

    Widget? trailingIcon(String key) {
      if (!hasAnswered.value) return null;
      if (key == mcq.correctOption) {
        return Icon(Icons.check_circle, color: colors.tertiary);
      }
      if (key == selected.value) {
        return Icon(Icons.cancel, color: colors.error);
      }
      return null;
    }

    final isCorrect = selected.value == mcq.correctOption;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Multiple Choice',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question
          Card(
            elevation: 0,
            color: colors.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MarkdownBody(
                data: mcq.questionMd,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.titleMedium?.copyWith(height: 1.5),
                  code: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Select the best answer',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          // Options
          ...List.generate(4, (i) {
            final key = _optionKeys[i];
            final label = _optionLabels[i];
            final text = options[i];
            final trail = trailingIcon(key);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => selectOption(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardColor(key),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor(key),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              borderColor(key).withAlpha(50),
                          child: Text(
                            label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: borderColor(key),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            text,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        ?trail,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Explanation
          if (hasAnswered.value)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrect
                    ? colors.tertiaryContainer
                    : colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect
                      ? colors.tertiary
                      : colors.secondary,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect
                        ? Icons.emoji_events
                        : Icons.info_outline,
                    color: isCorrect
                        ? colors.tertiary
                        : colors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCorrect ? 'Correct! 🎉' : 'Not quite!',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isCorrect
                                ? colors.tertiary
                                : colors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        MarkdownBody(
                          data: mcq.explanationMd,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(theme)
                                  .copyWith(
                            p: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}