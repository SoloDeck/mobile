import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';

class GetProposalUseCase {
  const GetProposalUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<Proposal> call(String id) => _repository.getProposal(id);
}
