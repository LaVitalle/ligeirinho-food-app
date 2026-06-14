import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'auth_service.dart';

class PasswordRecoveryState {
  final String email;
  final String code;
  final bool loading;
  final String? error;

  const PasswordRecoveryState({
    this.email = '',
    this.code = '',
    this.loading = false,
    this.error,
  });

  PasswordRecoveryState copyWith({
    String? email,
    String? code,
    bool? loading,
    String? error,
  }) =>
      PasswordRecoveryState(
        email: email ?? this.email,
        code: code ?? this.code,
        loading: loading ?? this.loading,
        error: error,
      );
}

class PasswordRecoveryNotifier extends StateNotifier<PasswordRecoveryState> {
  final AuthService _service;

  PasswordRecoveryNotifier(this._service) : super(const PasswordRecoveryState());

  Future<bool> requestCode(String email) async {
    state = state.copyWith(loading: true, error: null, email: email);
    try {
      await _service.forgotPassword(email);
      state = state.copyWith(loading: false, email: email);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    state = state.copyWith(loading: true, error: null, code: code);
    try {
      await _service.verifyCode(state.email, code);
      state = state.copyWith(loading: false, code: code);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.resetPassword(state.email, state.code, newPassword);
      state = const PasswordRecoveryState();
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final passwordRecoveryProvider =
    StateNotifierProvider<PasswordRecoveryNotifier, PasswordRecoveryState>((ref) {
  return PasswordRecoveryNotifier(ref.watch(authServiceProvider));
});
