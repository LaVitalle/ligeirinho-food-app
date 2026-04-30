import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/repositories/auth_repository.dart';
import '../models/auth_requests.dart';
import '../models/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<VerifyRecoveryCodeSubmitted>(_onVerifyRecoveryCodeSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<SessionRequested>(_onSessionRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await repository.login(event.email, event.password);
      emit(AuthSuccess(authResponse: response));
      emit(Authenticated(user: response.user));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await repository.register(event.request);
      emit(AuthSuccess(authResponse: response));
      emit(Authenticated(user: response.user));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await repository.forgotPassword(event.email);
      emit(const AuthActionSuccess(message: 'Código enviado para o e-mail.'));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onVerifyRecoveryCodeSubmitted(
    VerifyRecoveryCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await repository.verifyRecoveryCode(email: event.email, code: event.code);
      emit(const AuthActionSuccess(message: 'Código validado com sucesso.'));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await repository.resetPassword(event.request);
      emit(const AuthActionSuccess(message: 'Senha redefinida com sucesso.'));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSessionRequested(
    SessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLogged = await repository.hasSession();
    if (!isLogged) {
      emit(Unauthenticated());
      return;
    }

    final user = await repository.getCurrentUser();
    if (user == null) {
      emit(Unauthenticated());
      return;
    }

    emit(Authenticated(user: user));
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();
    emit(Unauthenticated());
  }

  AuthRepository get authRepository => repository;

  Future<UserModel?> getCurrentUser() {
    return authRepository.getCurrentUser();
  }

  Future<void> logout() {
    return authRepository.logout();
  }

  Future<bool> hasSession() {
    return authRepository.hasSession();
  }

  Future<void> forgotPassword(String email) {
    return authRepository.forgotPassword(email);
  }

  Future<void> verifyRecoveryCode({required String email, required String code}) {
    return authRepository.verifyRecoveryCode(email: email, code: code);
  }

  Future<void> resetPassword(ResetPasswordRequestModel request) {
    return authRepository.resetPassword(request);
  }
}
