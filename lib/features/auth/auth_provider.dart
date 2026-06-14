import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import 'auth_service.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  void login(UserModel user) => state = user;
  void logout() => state = null;

  Future<void> updateProfile(
      {String? name,
      String? phone,
      String? registration,
      String? institution}) async {
    if (state == null) return;

    // Call API to update profile
    await _authService.updateProfile(name: name, phone: phone);

    state = state!.copyWith(
      name: name,
      phoneNumber: phone,
      registration: registration,
      institution: institution,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
