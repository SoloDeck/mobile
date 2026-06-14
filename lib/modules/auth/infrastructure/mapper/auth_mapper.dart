import 'package:solodesk_mobile/modules/auth/domain/entities/auth_token.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_user.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/auth_token_response_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/user_response_dto.dart';

extension AuthTokenResponseDtoMapper on AuthTokenResponseDto {
  AuthToken toDomain() => AuthToken(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType,
    expiresIn: expiresIn,
  );
}

extension UserResponseDtoMapper on UserResponseDto {
  AuthUser toDomain() => AuthUser(
    id: id,
    email: email,
    fullName: fullName,
    role: role,
    status: status,
    avatarUrl: avatarUrl,
  );
}
