import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/list_deal_attachments_usecase.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deal_attachments_repository_impl.dart';

part 'deal_attachments_provider.g.dart';

@riverpod
Future<List<DealAttachment>> dealAttachments(Ref ref, String dealId) {
  final useCase = ListDealAttachmentsUseCase(
    ref.watch(dealAttachmentsRepositoryProvider),
  );
  return useCase(dealId);
}
