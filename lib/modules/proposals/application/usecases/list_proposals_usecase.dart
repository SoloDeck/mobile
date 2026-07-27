import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_query.dart';

class ListProposalsUseCase {
  const ListProposalsUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<ProposalListPage> call({
    ProposalListFilter filter = const ProposalListFilter(),
    int page = 1,
    int pageSize = 20,
  }) =>
      _repository.listProposals(filter: filter, page: page, pageSize: pageSize);
}
