import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';

class DeleteProposalUseCase {
  const DeleteProposalUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<void> call(String id) => _repository.deleteProposal(id);
}
