import 'package:freezed_annotation/freezed_annotation.dart';

part 'proposal_request_dto.freezed.dart';
part 'proposal_request_dto.g.dart';

/// Request body dùng CHUNG cho `POST /proposals` (tạo mới) và
/// `PATCH /proposals/{id}` (sửa nội dung) — đúng theo backend: PATCH bắt buộc
/// phải gửi cả `deal_id` lẫn `content` dù server chỉ thật sự áp dụng
/// `content`.
@freezed
abstract class ProposalRequestDto with _$ProposalRequestDto {
  const factory ProposalRequestDto({
    @JsonKey(name: 'deal_id') required String dealId,
    required Map<String, dynamic> content,
    @Default('draft') String status,
  }) = _ProposalRequestDto;

  factory ProposalRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalRequestDtoFromJson(json);
}
