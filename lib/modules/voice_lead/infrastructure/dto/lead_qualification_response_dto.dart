import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_qualification_response_dto.freezed.dart';
part 'lead_qualification_response_dto.g.dart';

@freezed
abstract class LeadQualificationResponseDto
    with _$LeadQualificationResponseDto {
  const factory LeadQualificationResponseDto({
    required double score,
    required String recommendation,
    @JsonKey(name: 'suggested_deal_title') required String suggestedDealTitle,
    @JsonKey(name: 'suggested_client_name') String? suggestedClientName,
    String? summary,
  }) = _LeadQualificationResponseDto;

  factory LeadQualificationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LeadQualificationResponseDtoFromJson(json);
}
