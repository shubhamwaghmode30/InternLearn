import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nexus/features/slides/data/models/slide_match.dart';
import 'package:nexus/features/slides/presentation/widgets/components/match_slide_badge.dart';
import 'package:nexus/features/slides/presentation/widgets/components/match_slide_columns.dart';
import 'package:nexus/features/slides/presentation/widgets/components/match_slide_completion_section.dart';
import 'package:nexus/features/slides/presentation/widgets/components/match_slide_hint_text.dart';
import 'package:nexus/features/slides/presentation/widgets/components/match_slide_question_card.dart';

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

    // Shuffle right items exactly once
    final shuffledRight = useMemoized(() {
      final list = [...match.rightItems];
      list.shuffle();
      return list;
    }, const []);

    // Build correct lookup: leftId → rightId
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
          MatchSlideBadge(theme: theme),
          const SizedBox(height: 16),

          MatchSlideQuestionCard(theme: theme, question: match.question),

          const SizedBox(height: 8),
          MatchSlideHintText(
            theme: theme,
            hasSelectedLeft: selectedLeft.value != null,
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
