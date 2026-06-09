import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/config/app_config.dart';
import 'package:solodesk_mobile/core/network/auth_interceptor.dart';
import 'package:solodesk_mobile/core/network/error_interceptor.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'api_client.g.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  // Unwrap AppException from DioException so callers receive typed domain errors.
  Never _unwrap(DioException e) {
    final inner = e.error;
    if (inner is AppException) throw inner;
    throw e;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _unwrap(e);
    }
  }

  Future<Response<T>> post<T>(String path, {Object? data, Options? options}) async {
    try {
      return await _dio.post<T>(path, data: data, options: options);
    } on DioException catch (e) {
      _unwrap(e);
    }
  }

  Future<Response<T>> put<T>(String path, {Object? data, Options? options}) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      _unwrap(e);
    }
  }

  Future<Response<T>> patch<T>(String path, {Object? data, Options? options}) async {
    try {
      return await _dio.patch<T>(path, data: data, options: options);
    } on DioException catch (e) {
      _unwrap(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, options: options);
    } on DioException catch (e) {
      _unwrap(e);
    }
  }
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    ref.read(authInterceptorProvider),
    ErrorInterceptor(),
    if (AppConfig.isDevelopment)
      PrettyDioLogger(requestBody: true, responseBody: true, compact: false),
  ]);

  return ApiClient(dio);
}
