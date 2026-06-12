import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_user.dart';

part 'auth_token.freezed.dart';

@freezed
abstract class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    AuthUser? user,
  }) = _AuthToken;
}
