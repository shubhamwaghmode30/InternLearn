import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/providers/auth_provider.dart';
import 'package:interactive_learn/core/providers/theme_provider.dart';
import 'package:interactive_learn/core/providers/user_profile_provider.dart';
import 'package:interactive_learn/core/singleton.dart';
import 'package:interactive_learn/core/widgets/loading_skeletons.dart';
import 'package:interactive_learn/screens/profile/edit_profile_screen.dart';
import 'package:random_avatar/random_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(appThemeProvider.notifier);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);

    final email = user?.email ?? 'Unknown';
    final fallbackName = email.split('@').first;

    Future<void> handleLogout() async {
      try {
        await supabase.auth.signOut();
        // AuthGate in main.dart will automatically navigate to LoginPage
      } catch (e) {
        logger.e('Logout error', error: e);
      }
    }

    return profileAsync.when(
      loading: () => const ProfileSkeleton(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (profile) {
        final displayName = profile?.name.trim().isNotEmpty == true
            ? profile!.name
            : fallbackName;
        final avatarSeed = profile?.avatarSeed.trim().isNotEmpty == true
            ? profile!.avatarSeed
            : 'guest_$fallbackName';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: ClipOval(
                  child: RandomAvatar(
                    avatarSeed,
                    width: 104,
                    height: 104,
                    trBackground: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.email.isNotEmpty == true ? profile!.email : email,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'XP: ${profile?.totalXp ?? 0}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(profile?.email.isNotEmpty == true
                          ? profile!.email
                          : email),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Manage Profile'),
                      subtitle:
                          const Text('Edit your name and choose a fun avatar'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      subtitle: const Text('Manage your notifications'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.brightness_6_outlined),
                      title: const Text('Theme'),
                      subtitle: const Text('Light / Dark mode'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        theme.toggleTheme();
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: handleLogout,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
