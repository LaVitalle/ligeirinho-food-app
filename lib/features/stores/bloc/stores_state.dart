import 'package:equatable/equatable.dart';

import '../models/institution_model.dart';

abstract class StoresState extends Equatable {
  const StoresState();

  @override
  List<Object?> get props => [];
}

class StoresInitial extends StoresState {}

class StoresLoading extends StoresState {}

class StoresLoaded extends StoresState {
  final List<InstitutionModel> institutions;

  const StoresLoaded({required this.institutions});

  @override
  List<Object?> get props => [institutions];
}

class StoresError extends StoresState {
  final String message;

  const StoresError({required this.message});

  @override
  List<Object?> get props => [message];
}
