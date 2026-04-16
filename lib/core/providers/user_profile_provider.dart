import 'package:interactive_learn/core/models/user_profile.dart';
import 'package:interactive_learn/core/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_provider.g.dart';

@riverpod
FutureOr<UserProfile?> userProfile(Ref ref) async {
  return AuthService.getUserProfile();
}
