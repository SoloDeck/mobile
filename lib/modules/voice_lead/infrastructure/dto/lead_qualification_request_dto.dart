import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_qualification_request_dto.freezed.dart';
part 'lead_qualification_request_dto.g.dart';

@freezed
abstract class LeadQualificationRequestDto with _$LeadQualificationRequestDto {
  const factory LeadQualificationRequestDto({
    @JsonKey(name: 'inquiry_text') required String inquiryText,
    @JsonKey(name: 'service_category', includeIfNull: false)
    String? serviceCategory,
  }) = _LeadQualificationRequestDto;

  factory LeadQualificationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LeadQualificationRequestDtoFromJson(json);
}
