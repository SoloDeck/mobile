import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_project_request_dto.freezed.dart';
part 'create_project_request_dto.g.dart';

/// Request body for `POST /projects`. Null fields are omitted. Dates are sent as
/// `YYYY-MM-DD` strings (the contract `date` format).
@freezed
abstract class CreateProjectRequestDto with _$CreateProjectRequestDto {
  const factory CreateProjectRequestDto({
    required String name,
    @JsonKey(name: 'deal_id', includeIfNull: false) String? dealId,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(name: 'start_date', includeIfNull: false) String? startDate,
    @JsonKey(name: 'end_date', includeIfNull: false) String? endDate,
  }) = _CreateProjectRequestDto;

  factory CreateProjectRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectRequestDtoFromJson(json);
}
