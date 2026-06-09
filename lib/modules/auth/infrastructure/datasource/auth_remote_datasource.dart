import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/auth_token_response_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/login_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._client);

  final ApiClient _client;

  Future<AuthTokenResponseDto> login(LoginRequestDto request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: request.toJson(),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => AuthTokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<AuthTokenResponseDto> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.authRegister,
      data: {'email': email, 'password': password, 'full_name': fullName},
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => AuthTokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<AuthTokenResponseDto> loginWithGoogle(String idToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.authGoogleCallback,
      data: {'id_token': idToken},
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => AuthTokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<void> requestPasswordReset(String email) async {
    await _client.post<void>(
      ApiEndpoints.authForgotPassword,
      data: {'email': email},
    );
  }

  Future<void> logout() async {
    await _client.post<void>(ApiEndpoints.authLogout);
  }
}
