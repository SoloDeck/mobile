import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_query.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';

/// Hợp đồng dữ liệu của module báo giá. Triển khai ở
/// `infrastructure/repository/proposals_repository_impl.dart`.
abstract interface class ProposalsRepository {
  Future<ProposalListPage> listProposals({
    ProposalListFilter filter = const ProposalListFilter(),
    int page = 1,
    int pageSize = 20,
  });

  Future<Proposal> getProposal(String id);

  Future<Proposal> createProposal({
    required String dealId,
    required ProposalContent content,
  });

  Future<Proposal> updateProposalContent({
    required String id,
    required String dealId,
    required ProposalContent content,
  });

  Future<Proposal> sendProposal(String id);

  Future<Proposal> transitionStatus({
    required String id,
    required ProposalStatus target,
  });

  Future<Proposal> generateFromDeal(String dealId);

  Future<Proposal> regenerateContent(String id);

  Future<List<int>> downloadPdf(String id);

  Future<void> deleteProposal(String id);
}
