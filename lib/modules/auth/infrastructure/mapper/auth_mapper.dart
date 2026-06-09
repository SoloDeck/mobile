import 'package:solodesk_mobile/modules/auth/domain/entities/auth_token.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/auth_token_response_dto.dart';

extension AuthTokenResponseDtoMapper on AuthTokenResponseDto {
  AuthToken toDomain() => AuthToken(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType,
  );
}
