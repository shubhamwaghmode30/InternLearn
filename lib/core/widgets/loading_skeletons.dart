import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class AppListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const AppListSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: SkeletonListView(
        scrollable: true,
        itemCount: itemCount,
        padding: padding,
        spacing: 10,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SkeletonListTile(
            hasSubtitle: true,
            leadingStyle: const SkeletonAvatarStyle(
              width: 44,
              height: 44,
              shape: BoxShape.circle,
            ),
            titleStyle: const SkeletonLineStyle(height: 14),
            subtitleStyle: const SkeletonLineStyle(height: 10),
          ),
        ),
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ShimmerWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    width: 48,
                    height: 48,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: const [
                      SkeletonLine(style: SkeletonLineStyle(height: 14)),
                      SizedBox(height: 8),
                      SkeletonLine(style: SkeletonLineStyle(height: 10, maxLength: 180, minLength: 120, randomLength: true)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonLine(
              style: SkeletonLineStyle(
                width: 140,
                height: 16,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: 34,
                          height: 34,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Spacer(),
                      SkeletonLine(style: SkeletonLineStyle(height: 12)),
                      SizedBox(height: 6),
                      SkeletonLine(
                        style: SkeletonLineStyle(
                          height: 9,
                          maxLength: 90,
                          minLength: 60,
                          randomLength: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ShimmerWidget(
        child: Column(
          children: [
            const SkeletonAvatar(
              style: SkeletonAvatarStyle(
                width: 104,
                height: 104,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            const SkeletonLine(style: SkeletonLineStyle(width: 160, height: 16)),
            const SizedBox(height: 8),
            const SkeletonLine(style: SkeletonLineStyle(width: 220, height: 12)),
            const SizedBox(height: 24),
            const AppListSkeleton(itemCount: 4, padding: EdgeInsets.zero),
          ],
        ),
      ),
    );
  }
}

class ProgressSkeleton extends StatelessWidget {
  const ProgressSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        children: [
          const SkeletonAvatar(
            style: SkeletonAvatarStyle(
              width: double.infinity,
              height: 130,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: SkeletonAvatar(
                  style: SkeletonAvatarStyle(height: 92, borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonAvatar(
                  style: SkeletonAvatarStyle(height: 92, borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: SkeletonAvatar(
                  style: SkeletonAvatarStyle(height: 92, borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SkeletonAvatar(
                  style: SkeletonAvatarStyle(height: 92, borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonAvatar(
            style: SkeletonAvatarStyle(
              width: double.infinity,
              height: 96,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          const SizedBox(height: 14),
          const AppListSkeleton(itemCount: 4, padding: EdgeInsets.zero),
        ],
      ),
    );
  }
}