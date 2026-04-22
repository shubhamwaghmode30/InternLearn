import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus/core/landing/widgets/home_skeleton.dart';
import 'package:nexus/features/auth/data/riverpod/auth_provider.dart';
import 'package:nexus/features/content/data/riverpod/content_provider.dart';
import 'package:nexus/core/landing/widgets/subject_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final subjectsAsync = ref.watch(subjectProvider);
    final displayName = user?.email?.split('@').first ?? 'Learner';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ──────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  displayName[0].toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $displayName!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Keep learning, keep growing.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Subjects header ───────────────────────────────────────
          Text(
            'Subjects',
            // textWidthBasis: ,
            textAlign: TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // ── Subjects grid ─────────────────────────────────────────
          subjectsAsync.when(
            data: (subjects) => subjects.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No subjects available yet.')),
                  )
                : SubjectGrid(subjects: subjects),
            loading: () => const HomeSkeleton(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Failed to load subjects: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
