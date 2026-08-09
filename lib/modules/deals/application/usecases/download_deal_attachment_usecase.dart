import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_attachments_repository.dart';

class DownloadDealAttachmentUseCase {
  const DownloadDealAttachmentUseCase(this._repository);

  final DealAttachmentsRepository _repository;

  Future<List<int>> call(String attachmentId) =>
      _repository.downloadAttachment(attachmentId);
}
