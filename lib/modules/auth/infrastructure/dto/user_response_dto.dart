import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/preferences_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/professional_profile_dto.dart';

part 'user_response_dto.freezed.dart';
part 'user_response_dto.g.dart';

@freezed
abstract class UserResponseDto with _$UserResponseDto {
  const factory UserResponseDto({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    required String role,
    required String status,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    String? phone,
    @JsonKey(name: 'professional_profile')
    ProfessionalProfileDto? professionalProfile,
    PreferencesDto? preferences,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _UserResponseDto;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);
}
