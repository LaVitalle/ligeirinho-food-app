import '../../models/institution_model.dart';
import '../datasources/institutions_remote_data_source.dart';

abstract class InstitutionsRepository {
  Future<List<InstitutionModel>> fetchInstitutions({int page = 1, int perPage = 10});
  Future<InstitutionModel> validateAccessCode(String accessCode);
}

class InstitutionsRepositoryImpl implements InstitutionsRepository {
  final InstitutionsRemoteDataSource remoteDataSource;

  InstitutionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InstitutionModel>> fetchInstitutions({
    int page = 1,
    int perPage = 10,
  }) {
    return remoteDataSource.fetchInstitutions(page: page, perPage: perPage);
  }

  @override
  Future<InstitutionModel> validateAccessCode(String accessCode) {
    return remoteDataSource.validateAccessCode(accessCode);
  }
}
