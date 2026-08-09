import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_attachments_repository.dart';

class DeleteDealAttachmentUseCase {
  const DeleteDealAttachmentUseCase(this._repository);

  final DealAttachmentsRepository _repository;

  Future<void> call(String attachmentId) =>
      _repository.deleteAttachment(attachmentId);
}
