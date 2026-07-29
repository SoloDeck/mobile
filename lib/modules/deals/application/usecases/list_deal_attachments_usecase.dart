import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_attachments_repository.dart';

class ListDealAttachmentsUseCase {
  const ListDealAttachmentsUseCase(this._repository);

  final DealAttachmentsRepository _repository;

  Future<List<DealAttachment>> call(String dealId) =>
      _repository.listAttachments(dealId);
}
