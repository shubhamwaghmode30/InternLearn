import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/models/search_result_item.dart';
import 'package:interactive_learn/core/providers/search_provider.dart';
import 'package:interactive_learn/core/widgets/loading_skeletons.dart';
import 'package:interactive_learn/screens/content/chapters_screen.dart';
import 'package:interactive_learn/screens/content/subtopics_screen.dart';
import 'package:interactive_learn/screens/content/topics_screen.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState('');
    final debouncedQuery = useState('');
    final debouncer = useMemoized(Debouncer.new);

    final resultsAsync = ref.watch(contentSearchProvider(debouncedQuery.value));

    useEffect(() {
      void onChanged() {
        final value = searchController.text;
        query.value = value;
        debouncer.debounce(
          duration: const Duration(milliseconds: 400),
          onDebounce: () {
            debouncedQuery.value = value;
          },
        );
      }

      searchController.addListener(onChanged);
      return () => searchController.removeListener(onChanged);
    }, [searchController, debouncer]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search subjects, chapters, topics, subtopics...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        query.value = '';
                        debouncedQuery.value = '';
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: query.value.trim().isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.travel_explore_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Search across all learning levels',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : resultsAsync.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'No results for "${debouncedQuery.value}"',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      final subjectResults =
                          results.where((r) => r.type == SearchEntityType.subject).toList();
                      final chapterResults =
                          results.where((r) => r.type == SearchEntityType.chapter).toList();
                      final topicResults =
                          results.where((r) => r.type == SearchEntityType.topic).toList();
                      final subtopicResults =
                          results.where((r) => r.type == SearchEntityType.subtopic).toList();

                      return ListView(
                        children: [
                          _buildSection(
                            context,
                            label: 'Subjects',
                            icon: Icons.menu_book_rounded,
                            items: subjectResults,
                          ),
                          _buildSection(
                            context,
                            label: 'Chapters',
                            icon: Icons.layers_rounded,
                            items: chapterResults,
                          ),
                          _buildSection(
                            context,
                            label: 'Topics',
                            icon: Icons.flag_rounded,
                            items: topicResults,
                          ),
                          _buildSection(
                            context,
                            label: 'Subtopics',
                            icon: Icons.auto_awesome_rounded,
                            items: subtopicResults,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    loading: () => const AppListSkeleton(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(SearchEntityType type) {
    switch (type) {
      case SearchEntityType.subject:
        return Icons.menu_book_rounded;
      case SearchEntityType.chapter:
        return Icons.layers_rounded;
      case SearchEntityType.topic:
        return Icons.flag_rounded;
      case SearchEntityType.subtopic:
        return Icons.auto_awesome_rounded;
    }
  }

  Widget _buildSection(
    BuildContext context, {
    required String label,
    required IconData icon,
    required List<SearchResultItem> items,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ResultCard(
                icon: _iconForType(item.type),
                title: item.title,
                subtitle: item.subtitle,
                onTap: () => _openResult(context, item),
              ),
            )),
        const SizedBox(height: 8),
      ],
    );
  }

  void _openResult(BuildContext context, SearchResultItem result) {
    switch (result.type) {
      case SearchEntityType.subject:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChaptersPage(subject: result.subject)),
        );
        break;
      case SearchEntityType.chapter:
        final chapter = result.chapter;
        if (chapter == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TopicsScreen(subject: result.subject, chapter: chapter),
          ),
        );
        break;
      case SearchEntityType.topic:
        final chapter = result.chapter;
        final topic = result.topic;
        if (chapter == null || topic == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubtopicsScreen(
              subject: result.subject,
              chapter: chapter,
              topic: topic,
            ),
          ),
        );
        break;
      case SearchEntityType.subtopic:
        final chapter = result.chapter;
        final topic = result.topic;
        if (chapter == null || topic == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubtopicsScreen(
              subject: result.subject,
              chapter: chapter,
              topic: topic,
            ),
          ),
        );
        break;
    }
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResultCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Go To'),
            ),
          ],
        ),
      ),
    );
  }
}