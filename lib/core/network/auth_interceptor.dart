import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';

part 'auth_interceptor.g.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenManager);

  final TokenManager _tokenManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tokenManager.refreshToken();
      if (refreshed) {
        final token = await _tokenManager.getAccessToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await Dio().fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          await _tokenManager.clearTokens();
        }
      } else {
        await _tokenManager.clearTokens();
      }
    }
    handler.next(err);
  }
}

@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(Ref ref) {
  return AuthInterceptor(ref.read(tokenManagerProvider));
}
