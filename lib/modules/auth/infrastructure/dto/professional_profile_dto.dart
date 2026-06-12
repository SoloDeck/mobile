import 'package:freezed_annotation/freezed_annotation.dart';

part 'professional_profile_dto.freezed.dart';
part 'professional_profile_dto.g.dart';

@freezed
abstract class ProfessionalProfileDto with _$ProfessionalProfileDto {
  const factory ProfessionalProfileDto({
    List<String>? skills,
    String? specialization,
    @JsonKey(name: 'default_hourly_rate') double? defaultHourlyRate,
    String? currency,
    @JsonKey(name: 'portfolio_url') String? portfolioUrl,
    @JsonKey(name: 'business_name') String? businessName,
  }) = _ProfessionalProfileDto;

  factory ProfessionalProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalProfileDtoFromJson(json);
}
