sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException(super.message);

  factory NetworkException.timeout() =>
      const NetworkException('Request timed out');
  factory NetworkException.noConnection() =>
      const NetworkException('No internet connection');
  factory NetworkException.rateLimited() =>
      const NetworkException('Too many requests — please wait and retry');
  factory NetworkException.unknown(String? msg) =>
      NetworkException(msg ?? 'Unknown network error');
}

final class AuthException extends AppException {
  const AuthException(super.message);

  factory AuthException.unauthenticated() =>
      const AuthException('Session expired — please log in again');
  factory AuthException.forbidden() =>
      const AuthException('You do not have permission to do this');
  factory AuthException.invalidCredentials() =>
      const AuthException('Invalid email or password');
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

final class ConflictException extends AppException {
  const ConflictException(super.message);
}

final class ServerException extends AppException {
  const ServerException(this.statusCode, super.message);
  final int statusCode;
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class AIQualificationException extends AppException {
  const AIQualificationException(super.message);
  factory AIQualificationException.parseError() =>
      const AIQualificationException('Không thể phân tích phản hồi AI');
  factory AIQualificationException.serviceUnavailable() =>
      const AIQualificationException('Dịch vụ AI không khả dụng');
}
