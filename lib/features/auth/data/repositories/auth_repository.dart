import '../datasources/auth_remote_data_source.dart';
import '../../models/auth_response_model.dart';
import '../../models/auth_requests.dart';
import '../../models/user_model.dart';
import '../../../../core/storage/session_storage.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<void> forgotPassword(String email);
  Future<void> verifyRecoveryCode({required String email, required String code});
  Future<void> resetPassword(ResetPasswordRequestModel request);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> hasSession();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SessionStorage sessionStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sessionStorage,
  });

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    await sessionStorage.saveSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: response.user,
    );
    return response;
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await remoteDataSource.register(request);
    await sessionStorage.saveSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: response.user,
    );
    return response;
  }

  @override
  Future<void> forgotPassword(String email) {
    return remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> verifyRecoveryCode({required String email, required String code}) {
    return remoteDataSource.verifyRecoveryCode(email: email, code: code);
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) {
    return remoteDataSource.resetPassword(request);
  }

  @override
  Future<void> logout() async {
    await sessionStorage.clear();
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return sessionStorage.getCurrentUser();
  }

  @override
  Future<bool> hasSession() async {
    final token = await sessionStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
