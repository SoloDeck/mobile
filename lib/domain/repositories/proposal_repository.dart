import 'package:mobile/domain/models/proposal.dart';

/// Interface cho repository quản lý Proposal (đề xuất).
abstract class ProposalRepository {
  /// Lấy tất cả proposals.
  Future<List<Proposal>> getProposals();

  /// Lấy proposals theo trạng thái.
  Future<List<Proposal>> getProposalsByStatus(String status);

  /// Duyệt và gửi proposal (one-tap approve & send).
  Future<Proposal> approveAndSend(String proposalId);
}
