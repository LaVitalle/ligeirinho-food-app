import 'package:dio/dio.dart';
import '../constants/app_env.dart';
import 'response_interceptor.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(ResponseInterceptor());

  return dio;
}
