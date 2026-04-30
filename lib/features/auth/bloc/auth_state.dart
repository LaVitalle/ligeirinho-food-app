import 'package:equatable/equatable.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponseModel authResponse;

  const AuthSuccess({required this.authResponse});

  @override
  List<Object?> get props => [authResponse];
}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthActionSuccess extends AuthState {
  final String message;

  const AuthActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
