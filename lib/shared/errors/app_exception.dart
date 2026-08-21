sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException(super.message);

  factory NetworkException.timeout() =>
      const NetworkException('Kết nối quá hạn');
  factory NetworkException.noConnection() =>
      const NetworkException('Không có kết nối mạng');
  factory NetworkException.rateLimited() =>
      const NetworkException('Quá nhiều yêu cầu — vui lòng đợi rồi thử lại');
  factory NetworkException.unknown(String? msg) =>
      NetworkException(msg ?? 'Lỗi mạng không xác định');
}

final class AuthException extends AppException {
  const AuthException(super.message);

  factory AuthException.unauthenticated() => const AuthException(
    'Phiên đăng nhập đã hết hạn — vui lòng đăng nhập lại',
  );
  factory AuthException.forbidden() =>
      const AuthException('Bạn không có quyền thực hiện thao tác này');
  factory AuthException.invalidCredentials() =>
      const AuthException('Email hoặc mật khẩu không đúng');
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
