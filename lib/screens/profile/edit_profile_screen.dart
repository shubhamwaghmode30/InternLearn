import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/providers/user_profile_provider.dart';
import 'package:interactive_learn/core/services/auth_service.dart';
import 'package:interactive_learn/core/widgets/loading_skeletons.dart';
import 'package:interactive_learn/screens/profile/avatar_picker_screen.dart';
import 'package:random_avatar/random_avatar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;
  String? _selectedAvatarSeed;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await AuthService.updateProfile(name: _nameController.text);
      if (!mounted) return;
      ref.invalidate(userProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileAsync.when(
        loading: () => const AppListSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          if (_nameController.text.isEmpty) {
            _nameController.text = profile.name;
          }

          _selectedAvatarSeed ??= profile.avatarSeed;
          final avatarSeed = (_selectedAvatarSeed?.trim().isNotEmpty ?? false)
              ? _selectedAvatarSeed!
              : 'user_avatar';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: ClipOval(
                        child: RandomAvatar(
                          avatarSeed,
                          width: 92,
                          height: 92,
                          trBackground: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Current Avatar',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.alternate_email_rounded),
                      title: const Text('Email'),
                      subtitle: Text(profile.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Name cannot be empty';
                      if (v.length < 2) return 'Name is too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.face_retouching_natural_rounded),
                      title: const Text('Avatar'),
                      subtitle: const Text('Choose from random avatars'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: RandomAvatar(
                              avatarSeed,
                              width: 30,
                              height: 30,
                              trBackground: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      onTap: () async {
                        final selectedSeed = await Navigator.of(context)
                            .push<String>(
                          MaterialPageRoute(
                            builder: (_) => AvatarPickerScreen(currentSeed: profile.avatarSeed),
                          ),
                        );
                        if (!mounted) return;
                        if (selectedSeed != null && selectedSeed.trim().isNotEmpty) {
                          setState(() => _selectedAvatarSeed = selectedSeed);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avatar selected, remember to save changes')),
                            );
                          } 
                        }
                        ref.invalidate(userProfileProvider);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
