import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_attachments_repository.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deal_attachments_remote_datasource.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/mapper/deal_attachment_mapper.dart';

part 'deal_attachments_repository_impl.g.dart';

/// No local cache: attachments are files, not app state worth persisting
/// offline — every call goes straight to the remote datasource.
class DealAttachmentsRepositoryImpl implements DealAttachmentsRepository {
  const DealAttachmentsRepositoryImpl(this._remote);

  final DealAttachmentsRemoteDatasource _remote;

  @override
  Future<List<DealAttachment>> listAttachments(String dealId) async {
    final dtos = await _remote.listAttachments(dealId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<DealAttachment> uploadAttachment({
    required String dealId,
    required String filePath,
    required String filename,
  }) async {
    final dto = await _remote.uploadAttachment(
      dealId: dealId,
      filePath: filePath,
      filename: filename,
    );
    return dto.toDomain();
  }

  @override
  Future<List<int>> downloadAttachment(String attachmentId) =>
      _remote.downloadAttachment(attachmentId);

  @override
  Future<void> deleteAttachment(String attachmentId) =>
      _remote.deleteAttachment(attachmentId);
}

@Riverpod(keepAlive: true)
DealAttachmentsRepository dealAttachmentsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  return DealAttachmentsRepositoryImpl(DealAttachmentsRemoteDatasource(client));
}
