import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';

class UpdateProposalContentUseCase {
  const UpdateProposalContentUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<Proposal> call({
    required String id,
    required String dealId,
    required ProposalContent content,
  }) => _repository.updateProposalContent(
    id: id,
    dealId: dealId,
    content: content,
  );
}
