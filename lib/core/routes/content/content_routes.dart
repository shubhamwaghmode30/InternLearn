import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus/core/routes/models/nav_payloads.dart';
import 'package:nexus/features/content/data/models/subject.dart';
import 'package:nexus/features/content/presentation/screens/chapters_screen.dart';
import 'package:nexus/features/content/presentation/screens/subtopics_screen.dart';
import 'package:nexus/features/content/presentation/screens/topics_screen.dart';

part 'content_routes.g.dart';


@TypedGoRoute<ChaptersRoute>(path: '/chapters')
class ChaptersRoute extends GoRouteData with $ChaptersRoute {
  const ChaptersRoute({required this.$extra});

  final Subject $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChaptersPage(subject: $extra);
  }
}

@TypedGoRoute<TopicsRoute>(path: '/topics')
class TopicsRoute extends GoRouteData with $TopicsRoute {
  const TopicsRoute({required this.$extra});

  final TopicsNavData $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TopicsScreen(subject: $extra.subject, chapter: $extra.chapter);
  }
}

@TypedGoRoute<SubtopicsRoute>(path: '/subtopics')
class SubtopicsRoute extends GoRouteData with $SubtopicsRoute {
  const SubtopicsRoute({required this.$extra});

  final SubtopicsNavData $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SubtopicsScreen(
      subject: $extra.subject,
      chapter: $extra.chapter,
      topic: $extra.topic,
    );
  }
}

