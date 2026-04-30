import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../models/city_model.dart';
import '../../models/state_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<StateModel>> fetchStates();
  Future<List<CityModel>> fetchCitiesByState(int stateId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio dio;

  LocationRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StateModel>> fetchStates() async {
    try {
      final response = await dio.get('/states');
      final data = response.data as List<dynamic>;
      return data
          .map((item) => StateModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Erro ao carregar estados');
    }
  }

  @override
  Future<List<CityModel>> fetchCitiesByState(int stateId) async {
    try {
      final response = await dio.get('/cities/$stateId');
      final data = response.data as List<dynamic>;
      return data
          .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Erro ao carregar cidades');
    }
  }
}
