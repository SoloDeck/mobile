import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';

class CreateProposalUseCase {
  const CreateProposalUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<Proposal> call({
    required String dealId,
    required ProposalContent content,
  }) => _repository.createProposal(dealId: dealId, content: content);
}
