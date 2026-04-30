import 'package:equatable/equatable.dart';

import '../models/city_model.dart';
import '../models/state_model.dart';

class LocationState extends Equatable {
  final List<StateModel> states;
  final List<CityModel> cities;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.states = const [],
    this.cities = const [],
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    List<StateModel>? states,
    List<CityModel>? cities,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      states: states ?? this.states,
      cities: cities ?? this.cities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [states, cities, isLoading, error];
}
