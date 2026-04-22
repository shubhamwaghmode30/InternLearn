import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nexus/core/widgets/list_skeleton.dart';
import 'package:nexus/features/slides/data/riverpod/slide_provider.dart';
import 'package:nexus/features/slides/presentation/widgets/slide_viewer_body.dart';


class SlideViewerScreen extends HookConsumerWidget {
  final int subtopicId;
  final String subtopicTitle;

  const SlideViewerScreen({
    super.key,
    required this.subtopicId,
    required this.subtopicTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slidesAsync = ref.watch(slidesProvider(subtopicId));

    return slidesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(subtopicTitle)),
        body: const ListSkeleton(itemCount: 7),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(subtopicTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load slides', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(e.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
      data: (data) => SlideViewerBody(
        data: data,
        title: subtopicTitle,
        subtopicId: subtopicId,
      ),
    );
  }
}

