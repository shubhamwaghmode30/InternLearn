import 'dart:math';

import 'package:interactive_learn/core/models/user_profile.dart';
import 'package:interactive_learn/core/singleton.dart';

class AccountFilledDetails {
  String name;
  String email;
  String password;
  AccountFilledDetails({
    required this.name,
    required this.email,
    required this.password,
  });
}

class AuthService {
  static final Random _rng = Random();

  static String generateAvatarSeed() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      14,
      (_) => chars[_rng.nextInt(chars.length)],
    ).join();
  }

  static Future<void> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    logger.i('Login result: ${res.session != null ? "Success" : "Failed"}');
    return;
  }

  static Future<void> logout() async {
    await supabase.auth.signOut();
  }

  static Future<void> signUp(AccountFilledDetails details) async {
    final res = await supabase.auth.signUp(
      email: details.email,
      password: details.password,
    );
    logger.i('Sign-up result: ${res.user != null ? "Success" : "Failed"}');
    if (res.user != null) {
      final avatarSeed = generateAvatarSeed();
      await supabase.from('user_profile').insert({
        'user_id': res.user?.id,
        'name': details.name,
        'email': details.email,
        'avatar_seed': avatarSeed,
      });
    }

    return;
  }

  static Future<UserProfile?> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return Future.value(null);

    final data = await supabase
        .from('user_profile')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data == null) {
      final avatarSeed = generateAvatarSeed();
      await supabase.from('user_profile').insert({
        'user_id': user.id,
        'name': user.userMetadata?['name']?.toString() ?? '',
        'email': user.email ?? '',
        'avatar_seed': avatarSeed,
      });

      return getUserProfile();
    }

    final profile = UserProfile.fromJson(data);
    if (profile.avatarSeed.trim().isEmpty) {
      final avatarSeed = generateAvatarSeed();
      await updateProfile(avatarSeed: avatarSeed);
      return profile.copyWith(avatarSeed: avatarSeed);
    }

    return profile;
  }

  static Future<void> updateProfile({String? name, String? avatarSeed}) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final payload = <String, dynamic>{};
    if (name != null) {
      payload['name'] = name.trim();
    }
    if (avatarSeed != null && avatarSeed.trim().isNotEmpty) {
      payload['avatar_seed'] = avatarSeed.trim();
    }

    if (payload.isEmpty) return;

    await supabase.from('user_profile').update(payload).eq('user_id', user.id);
  }
}
