import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/mock_data/mock_data.dart';
import 'package:mobile/domain/models/proposal.dart';
import 'package:mobile/domain/repositories/proposal_repository.dart';

/// Mock implementation của [ProposalRepository].
class MockProposalRepository implements ProposalRepository {
  final List<Proposal> _proposals = List.from(MockData.proposals);

  @override
  Future<List<Proposal>> getProposals() async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    return List.unmodifiable(
      _proposals..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<List<Proposal>> getProposalsByStatus(String status) async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    final proposalStatus = ProposalStatus.values.byName(status);
    return _proposals.where((p) => p.status == proposalStatus).toList();
  }

  @override
  Future<Proposal> approveAndSend(String proposalId) async {
    await Future.delayed(AppConstants.mockNetworkDelay);

    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index == -1) throw Exception('Không tìm thấy đề xuất.');

    final updated = _proposals[index].copyWith(
      status: ProposalStatus.sent,
      sentAt: DateTime.now(),
    );
    _proposals[index] = updated;
    return updated;
  }
}
