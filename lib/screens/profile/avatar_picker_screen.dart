import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/providers/user_profile_provider.dart';
import 'package:interactive_learn/core/services/auth_service.dart';
import 'package:random_avatar/random_avatar.dart';

class AvatarPickerScreen extends ConsumerStatefulWidget {
  final String currentSeed;

  const AvatarPickerScreen({super.key, required this.currentSeed});

  @override
  ConsumerState<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends ConsumerState<AvatarPickerScreen> {
  late List<String> _seeds;
  int _shuffleCount = 0;

  @override
  void initState() {
    super.initState();
    _seeds = _generateAvatarSeeds(widget.currentSeed, 20, salt: 'init');
  }

  void _shuffle() {
    setState(() {
      _shuffleCount++;
      _seeds = _generateAvatarSeeds(
        widget.currentSeed,
        20,
        salt: 'shuffle_$_shuffleCount',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSeed = _seeds.contains(widget.currentSeed)
        ? widget.currentSeed
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Avatar'),
        actions: [
          IconButton(
            tooltip: 'Shuffle Avatars',
            onPressed: _shuffle,
            icon: const Icon(Icons.shuffle_rounded),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _seeds.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final seed = _seeds[index];
          final selected = seed == activeSeed;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              await AuthService.updateProfile(avatarSeed: seed);
              ref.invalidate(userProfileProvider);
              if (!context.mounted) return;
              Navigator.of(context).pop(seed);
            },
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  width: selected ? 2.2 : 1,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RandomAvatar(
                    seed,
                    width: 56,
                    height: 56,
                    trBackground: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _generateAvatarSeeds(String baseSeed, int count, {String salt = ''}) {
    final source = baseSeed.trim().isEmpty
        ? '${DateTime.now().microsecondsSinceEpoch}'
        : '${baseSeed}_$salt';
    final rng = Random(source.hashCode);
    const maxValue = 0x7fffffff;

    return List.generate(
      count,
      (index) => 'ava_${index}_${rng.nextInt(maxValue).toRadixString(16)}',
    );
  }
}
