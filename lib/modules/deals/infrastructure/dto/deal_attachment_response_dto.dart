import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal_attachment_response_dto.freezed.dart';
part 'deal_attachment_response_dto.g.dart';

/// Wire shape of `GET/POST /deals/{id}/attachments` items.
///
/// This endpoint is NOT in `contracts/openapi.yaml` — the contract only
/// documents the single-file `/deals/{id}/document` route. Shape here is
/// taken from the backend router (`deals/api/router.py`) and matches what
/// `web/src/services/dealAttachmentsService.ts` already consumes in
/// production.
@freezed
abstract class DealAttachmentResponseDto with _$DealAttachmentResponseDto {
  const factory DealAttachmentResponseDto({
    required String id,
    @JsonKey(name: 'deal_id') required String dealId,
    required String filename,
    @JsonKey(name: 'content_type') required String contentType,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    @JsonKey(name: 'ai_readable') required bool aiReadable,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _DealAttachmentResponseDto;

  factory DealAttachmentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DealAttachmentResponseDtoFromJson(json);
}
