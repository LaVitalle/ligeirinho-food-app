import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/location_repository.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository repository;

  LocationCubit({required this.repository}) : super(const LocationState());

  Future<void> fetchStates() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await repository.fetchStates();
      emit(state.copyWith(isLoading: false, states: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await repository.fetchCitiesByState(stateId);
      emit(state.copyWith(isLoading: false, cities: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
