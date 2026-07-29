import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_attachments_repository.dart';

class UploadDealAttachmentUseCase {
  const UploadDealAttachmentUseCase(this._repository);

  final DealAttachmentsRepository _repository;

  Future<DealAttachment> call({
    required String dealId,
    required String filePath,
    required String filename,
  }) => _repository.uploadAttachment(
    dealId: dealId,
    filePath: filePath,
    filename: filename,
  );
}
