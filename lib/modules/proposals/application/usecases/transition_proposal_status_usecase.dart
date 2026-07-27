import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';

class TransitionProposalStatusUseCase {
  const TransitionProposalStatusUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<Proposal> call({required String id, required ProposalStatus target}) =>
      _repository.transitionStatus(id: id, target: target);
}
