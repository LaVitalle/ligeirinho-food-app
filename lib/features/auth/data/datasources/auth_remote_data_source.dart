import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../models/auth_response_model.dart';
import '../../models/auth_requests.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<void> forgotPassword(String email);
  Future<void> verifyRecoveryCode({required String email, required String code});
  Future<void> resetPassword(ResetPasswordRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Falha ao efetuar login');
    } catch (e) {
      throw AppException('Erro inesperado ao efetuar login');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await dio.post('/auth/register', data: request.toJson());
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Falha ao registrar usuário');
    } catch (_) {
      throw AppException('Erro inesperado ao registrar usuário');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Falha ao enviar código');
    } catch (_) {
      throw AppException('Erro inesperado ao enviar código');
    }
  }

  @override
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  }) async {
    try {
      await dio.post('/auth/verify-code', data: {'email': email, 'code': code});
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Código inválido');
    } catch (_) {
      throw AppException('Erro inesperado ao validar código');
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    try {
      await dio.post('/auth/reset-password', data: request.toJson());
    } on DioException catch (e) {
      throw _mapDioException(e, defaultMessage: 'Falha ao redefinir senha');
    } catch (_) {
      throw AppException('Erro inesperado ao redefinir senha');
    }
  }

  AppException _mapDioException(
    DioException e, {
    required String defaultMessage,
  }) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return AppException(message, statusCode: statusCode);
      }
    }

    return AppException(e.message ?? defaultMessage, statusCode: statusCode);
  }
}
