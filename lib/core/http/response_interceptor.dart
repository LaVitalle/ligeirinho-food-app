import 'package:dio/dio.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      response.data = data['data'];
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = 'Tempo de conexão esgotado. Verifique sua internet.';
    } else if (err.type == DioExceptionType.connectionError) {
      message = 'Sem conexão com o servidor. Tente novamente mais tarde.';
    } else {
      final responseData = err.response?.data;
      if (responseData is Map<String, dynamic>) {
        message =
            responseData['message'] as String? ?? 'Ocorreu um erro inesperado.';
      } else {
        message = 'Ocorreu um erro inesperado.';
      }
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        message: message,
      ),
    );
  }
}
