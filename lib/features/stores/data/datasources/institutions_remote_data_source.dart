import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../models/institution_model.dart';

abstract class InstitutionsRemoteDataSource {
  Future<List<InstitutionModel>> fetchInstitutions({
    int page = 1,
    int perPage = 10,
  });

  Future<InstitutionModel> validateAccessCode(String accessCode);
}

class InstitutionsRemoteDataSourceImpl implements InstitutionsRemoteDataSource {
  final Dio dio;

  InstitutionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<InstitutionModel>> fetchInstitutions({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await dio.get(
        '/institutions',
        queryParameters: {'page': page, 'perPage': perPage},
      );
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map<String, dynamic> && data['items'] is List)
              ? data['items'] as List
              : <dynamic>[];

      return list
          .map((item) => InstitutionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Erro ao carregar instituições');
    }
  }

  @override
  Future<InstitutionModel> validateAccessCode(String accessCode) async {
    try {
      final response = await dio.get('/institutions/validate/$accessCode');
      return InstitutionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Código de instituição inválido');
    }
  }
}
