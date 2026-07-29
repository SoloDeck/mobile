import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_attachment_response_dto.dart';

extension DealAttachmentResponseDtoMapper on DealAttachmentResponseDto {
  DealAttachment toDomain() => DealAttachment(
    id: id,
    dealId: dealId,
    filename: filename,
    contentType: contentType,
    sizeBytes: sizeBytes,
    aiReadable: aiReadable,
    createdAt: DateTime.parse(createdAt),
  );
}
