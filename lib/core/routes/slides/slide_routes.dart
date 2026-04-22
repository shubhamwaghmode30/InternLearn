import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus/features/slides/presentation/screens/slide_viewer_screen.dart';

part 'slide_routes.g.dart';

@TypedGoRoute<SlideViewerRoute>(path: '/slides/:subtopicId')
class SlideViewerRoute extends GoRouteData with $SlideViewerRoute {
  const SlideViewerRoute({
    required this.subtopicId,
    required this.subtopicTitle,
  });

  final int subtopicId;
  final String subtopicTitle;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SlideViewerScreen(
      subtopicId: subtopicId,
      subtopicTitle: subtopicTitle,
    );
  }
}
