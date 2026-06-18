import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import 'auth_service.dart';

/// Chaves usadas para persistência local da sessão.
const _kUserKey = 'saved_user';

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  /// Faz login e persiste o usuário localmente.
  Future<void> login(UserModel user) async {
    state = user;
    await _persistUser(user);
  }

  /// Faz logout e limpa todos os dados persistidos.
  Future<void> logout() async {
    state = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kUserKey);
    await sp.remove('api_token');
  }

  /// Tenta restaurar a sessão salva ao reabrir o app.
  /// Retorna `true` se a sessão foi restaurada com sucesso.
  Future<bool> tryRestoreSession() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('api_token');
    final userJson = sp.getString(_kUserKey);

    if (token == null || userJson == null) return false;

    try {
      final decoded = json.decode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(decoded);
      state = user;
      return true;
    } catch (_) {
      // JSON corrompido — limpa dados e força novo login
      await sp.remove(_kUserKey);
      await sp.remove('api_token');
      return false;
    }
  }

  /// Busca dados atualizados do perfil na API e atualiza o estado + local.
  Future<void> fetchMe() async {
    try {
      final data = await _authService.getMe();
      if (state == null) return;
      state = state!.copyWith(
        name: data['fullName'] ?? data['name'] ?? state!.name,
        phoneNumber: data['phoneNumber'] ?? state!.phoneNumber,
        avatarUrl: data['profilePhotoUrl'] ?? state!.avatarUrl,
      );
      await _persistUser(state!);
    } catch (_) {}
  }

  /// Atualiza o perfil na API e persiste localmente.
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
    await _persistUser(state!);
  }

  /// Salva o UserModel no SharedPreferences como JSON.
  Future<void> _persistUser(UserModel user) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kUserKey, json.encode(user.toJson()));
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
