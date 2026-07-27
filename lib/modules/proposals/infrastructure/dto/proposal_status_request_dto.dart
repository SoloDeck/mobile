import 'package:freezed_annotation/freezed_annotation.dart';

part 'proposal_status_request_dto.freezed.dart';
part 'proposal_status_request_dto.g.dart';

/// Request body cho `PATCH /proposals/{id}/status` — chuyển trạng thái báo
/// giá (ví dụ `sent -> accepted`).
@freezed
abstract class ProposalStatusRequestDto with _$ProposalStatusRequestDto {
  const factory ProposalStatusRequestDto({required String status}) =
      _ProposalStatusRequestDto;

  factory ProposalStatusRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalStatusRequestDtoFromJson(json);
}
