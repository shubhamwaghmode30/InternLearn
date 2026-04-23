import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nexus/features/slides/data/models/slide_match.dart';
import 'package:nexus/features/slides/presentation/widgets/components/match_slide_columns.dart';
import 'package:nexus/features/slides/presentation/widgets/components/match_slide_completion_section.dart';

class MatchSlideWidget extends HookWidget {
  final SlideMatch match;
  final VoidCallback onCompleted;

  const MatchSlideWidget({
    super.key,
    required this.match,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final shuffledRight = useMemoized(() {
      final list = [...match.rightItems];
      list.shuffle();
      return list;
    }, const []);

    final correctMap = useMemoized(
      () => {for (final p in match.correctPairs) p.leftId: p.rightId},
      const [],
    );

    final selectedLeft = useState<String?>(null);
    final matchedPairs = useState<Map<String, String>>({}); // leftId → rightId
    final wrongPair = useState<(String, String)?>(null); // (leftId, rightId)

    // Timer ref so we can cancel if widget disposes
    final wrongTimer = useRef<Timer?>(null);

    useEffect(
      () =>
          () => wrongTimer.value?.cancel(),
      const [],
    );

    void selectLeft(String leftId) {
      if (matchedPairs.value.containsKey(leftId)) return;
      selectedLeft.value = selectedLeft.value == leftId ? null : leftId;
    }

    void selectRight(String rightId) {
      final left = selectedLeft.value;
      if (left == null) return;
      if (matchedPairs.value.values.contains(rightId)) return;

      if (correctMap[left] == rightId) {
        // Correct pair
        final updated = Map<String, String>.from(matchedPairs.value)
          ..[left] = rightId;
        matchedPairs.value = updated;
        selectedLeft.value = null;

        if (updated.length == match.correctPairs.length) {
          onCompleted();
        }
      } else {
        // Wrong pair — flash red, then clear
        wrongPair.value = (left, rightId);
        selectedLeft.value = null;
        wrongTimer.value?.cancel();
        wrongTimer.value = Timer(const Duration(milliseconds: 700), () {
          wrongPair.value = null;
        });
      }
    }

    Color leftBorder(String leftId) {
      final cs = theme.colorScheme;

      if (matchedPairs.value.containsKey(leftId)) return cs.primary;
      if (wrongPair.value?.$1 == leftId) return cs.error;
      if (selectedLeft.value == leftId) return cs.primary;

      return cs.outlineVariant;
    }

    Color leftBg(String leftId) {
      final cs = theme.colorScheme;

      if (matchedPairs.value.containsKey(leftId)) return cs.primaryContainer;
      if (wrongPair.value?.$1 == leftId) return cs.errorContainer;
      if (selectedLeft.value == leftId) return cs.primaryContainer;

      return cs.surface;
    }

    Color rightBorder(String rightId) {
      final cs = theme.colorScheme;

      if (matchedPairs.value.values.contains(rightId)) return cs.primary;
      if (wrongPair.value?.$2 == rightId) return cs.error;

      return cs.outlineVariant;
    }

    Color rightBg(String rightId) {
      final cs = theme.colorScheme;

      if (matchedPairs.value.values.contains(rightId)) {
        return cs.primaryContainer;
      }
      if (wrongPair.value?.$2 == rightId) return cs.errorContainer;

      return cs.surface;
    }

    final allMatched = matchedPairs.value.length == match.correctPairs.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(match.question, style: theme.textTheme.titleMedium),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedLeft.value != null
                ? 'Now tap the matching item on the right →'
                : 'Tap a left item to select it, then tap its match.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: selectedLeft.value != null
                  ? theme.colorScheme.primary
                  : Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          MatchSlideColumns(
            theme: theme,
            leftItems: match.leftItems,
            rightItems: shuffledRight,
            matchedPairs: matchedPairs.value,
            selectedLeftId: selectedLeft.value,
            wrongPair: wrongPair.value,
            leftBg: leftBg,
            leftBorder: leftBorder,
            rightBg: rightBg,
            rightBorder: rightBorder,
            onLeftTap: selectLeft,
            onRightTap: selectRight,
          ),

          MatchSlideCompletionSection(
            theme: theme,
            allMatched: allMatched,
            explanationMd: match.explanationMd,
          ),
        ],
      ),
    );
  }
}
