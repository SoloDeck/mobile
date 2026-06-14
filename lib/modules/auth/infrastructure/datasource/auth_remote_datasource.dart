import 'dart:io';

import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/auth_token_response_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/login_request_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/password_reset_confirm_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/refresh_request_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/register_request_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/user_response_dto.dart';
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
    final request = RegisterRequestDto(
      email: email,
      password: password,
      fullName: fullName,
    );
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.authRegister,
      data: request.toJson(),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => AuthTokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<AuthTokenResponseDto> loginWithGoogle(String idToken) async {
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.authGoogle,
      data: {'id_token': idToken, 'platform': platform},
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => AuthTokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<AuthTokenResponseDto> refreshToken(String refreshToken) async {
    final request = RefreshRequestDto(refreshToken: refreshToken);
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.authRefresh,
      data: request.toJson(),
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

  Future<void> confirmPasswordReset(String token, String newPassword) async {
    final request = PasswordResetConfirmDto(
      token: token,
      newPassword: newPassword,
    );
    await _client.post<void>(
      ApiEndpoints.authResetPassword,
      data: request.toJson(),
    );
  }

  Future<UserResponseDto> fetchMe() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.authMe,
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => UserResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<void> logout() async {
    await _client.post<void>(ApiEndpoints.authLogout);
  }
}
