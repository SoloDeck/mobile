import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_confirm_dto.freezed.dart';
part 'password_reset_confirm_dto.g.dart';

@freezed
abstract class PasswordResetConfirmDto with _$PasswordResetConfirmDto {
  const factory PasswordResetConfirmDto({
    required String token,
    @JsonKey(name: 'new_password') required String newPassword,
  }) = _PasswordResetConfirmDto;

  factory PasswordResetConfirmDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetConfirmDtoFromJson(json);
}
