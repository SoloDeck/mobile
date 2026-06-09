import 'package:dio/dio.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    final appException = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => NetworkException.timeout(),
      DioExceptionType.connectionError => NetworkException.noConnection(),
      DioExceptionType.badResponse => _mapStatusCode(response),
      _ => NetworkException.unknown(err.message),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        response: err.response,
        type: err.type,
      ),
    );
  }

  AppException _mapStatusCode(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final body = response?.data;
    final message = body is Map ? body['message'] as String? : null;

    return switch (status) {
      400 => ValidationException(message ?? 'Bad request'),
      401 => AuthException.unauthenticated(),
      403 => AuthException.forbidden(),
      404 => NotFoundException(message ?? 'Resource not found'),
      409 => ConflictException(message ?? 'Conflict'),
      422 => ValidationException(message ?? 'Unprocessable entity'),
      429 => NetworkException.rateLimited(),
      _ => ServerException(status, message ?? 'Server error'),
    };
  }
}
