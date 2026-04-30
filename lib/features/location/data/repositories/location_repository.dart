import '../../models/city_model.dart';
import '../../models/state_model.dart';
import '../datasources/location_remote_data_source.dart';

abstract class LocationRepository {
  Future<List<StateModel>> fetchStates();
  Future<List<CityModel>> fetchCitiesByState(int stateId);
}

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StateModel>> fetchStates() {
    return remoteDataSource.fetchStates();
  }

  @override
  Future<List<CityModel>> fetchCitiesByState(int stateId) {
    return remoteDataSource.fetchCitiesByState(stateId);
  }
}
