import 'package:equatable/equatable.dart';
import '../models/auth_requests.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final RegisterRequestModel request;

  const RegisterSubmitted({required this.request});

  @override
  List<Object?> get props => [request];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyRecoveryCodeSubmitted extends AuthEvent {
  final String email;
  final String code;

  const VerifyRecoveryCodeSubmitted({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class ResetPasswordSubmitted extends AuthEvent {
  final ResetPasswordRequestModel request;

  const ResetPasswordSubmitted({required this.request});

  @override
  List<Object?> get props => [request];
}

class SessionRequested extends AuthEvent {
  const SessionRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
