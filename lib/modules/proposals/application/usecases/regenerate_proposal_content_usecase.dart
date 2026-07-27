import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';

/// Sinh lại nội dung báo giá bằng AI rồi khôi phục 3 khoá riêng của mobile.
///
/// Server thay TOÀN BỘ `content` bằng bản AI mới sinh — 3 khoá mobile tự thêm
/// (`revision_rounds`/`valid_until`/`total`) bị mất theo vì AI generator chỉ
/// biết sinh 7 khoá đầu. Khôi phục lại bằng một lượt PATCH nữa, đè lên content
/// mới với 3 giá trị cũ đọc được TRƯỚC khi sinh lại.
class RegenerateProposalContentUseCase {
  const RegenerateProposalContentUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<Proposal> call(String id) async {
    final before = await _repository.getProposal(id);
    final regenerated = await _repository.regenerateContent(id);
    final restored = regenerated.content.copyWith(
      revisionRounds: before.content.revisionRounds,
      validUntil: before.content.validUntil,
      total: before.content.total,
    );
    return _repository.updateProposalContent(
      id: id,
      dealId: before.dealId,
      content: restored,
    );
  }
}
