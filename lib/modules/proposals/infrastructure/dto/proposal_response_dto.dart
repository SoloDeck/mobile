import 'package:freezed_annotation/freezed_annotation.dart';

part 'proposal_response_dto.freezed.dart';
part 'proposal_response_dto.g.dart';

/// Wire shape của một báo giá — khớp `ProposalResponse` phía backend
/// (`/proposals`). `content` giữ NGUYÊN dạng `Map<String, dynamic>` thô, KHÔNG
/// parse ở tầng DTO — việc đó thuộc về `ProposalContentX.fromMap` ở tầng
/// mapper, vì `content` là JSONB tự do không có schema cố định. Ngày/giờ giữ
/// dạng String, `DateTime.parse` ở mapper.
@freezed
abstract class ProposalResponseDto with _$ProposalResponseDto {
  const factory ProposalResponseDto({
    required String id,
    @JsonKey(name: 'deal_id') required String dealId,
    @JsonKey(name: 'owner_user_id') required String ownerUserId,
    @JsonKey(name: 'version_number') required int versionNumber,
    required String status,
    required Map<String, dynamic> content,
    @JsonKey(name: 'ai_generated') required bool aiGenerated,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'share_token') String? shareToken,
    @JsonKey(name: 'share_expires_at') String? shareExpiresAt,
    @JsonKey(name: 'sent_at') String? sentAt,
    @JsonKey(name: 'responded_at') String? respondedAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ProposalResponseDto;

  factory ProposalResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalResponseDtoFromJson(json);
}
