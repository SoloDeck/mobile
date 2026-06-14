import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token_response_dto.freezed.dart';
part 'auth_token_response_dto.g.dart';

@freezed
abstract class AuthTokenResponseDto with _$AuthTokenResponseDto {
  const factory AuthTokenResponseDto({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _AuthTokenResponseDto;

  factory AuthTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenResponseDtoFromJson(json);
}
