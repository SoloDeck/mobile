import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';

class GenerateProposalFromDealUseCase {
  const GenerateProposalFromDealUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<Proposal> call(String dealId) => _repository.generateFromDeal(dealId);
}
