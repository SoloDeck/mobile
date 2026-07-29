import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';

abstract interface class DealAttachmentsRepository {
  Future<List<DealAttachment>> listAttachments(String dealId);

  Future<DealAttachment> uploadAttachment({
    required String dealId,
    required String filePath,
    required String filename,
  });

  /// Raw file bytes — caller is responsible for writing them to a temp file.
  Future<List<int>> downloadAttachment(String attachmentId);

  Future<void> deleteAttachment(String attachmentId);
}
