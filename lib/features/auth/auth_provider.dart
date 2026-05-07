import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  void login(UserModel user) => state = user;
  void logout() => state = null;

  void updateProfile({String? name, String? email, String? registration, String? institution}) {
    if (state == null) return;
    state = state!.copyWith(
      name: name,
      email: email,
      registration: registration,
      institution: institution,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});
