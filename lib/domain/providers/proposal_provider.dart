import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/repositories/mock_proposal_repository.dart';
import 'package:mobile/domain/models/proposal.dart';
import 'package:mobile/domain/repositories/proposal_repository.dart';

/// Provider cho [ProposalRepository].
final proposalRepositoryProvider = Provider<ProposalRepository>((ref) {
  return MockProposalRepository();
});

/// Provider quản lý danh sách Proposal.
final proposalProvider =
    AsyncNotifierProvider<ProposalNotifier, List<Proposal>>(
        ProposalNotifier.new);

class ProposalNotifier extends AsyncNotifier<List<Proposal>> {
  @override
  FutureOr<List<Proposal>> build() async {
    final repo = ref.read(proposalRepositoryProvider);
    return repo.getProposals();
  }

  /// Duyệt và gửi proposal (one-tap).
  Future<bool> approveAndSend(String proposalId) async {
    final repo = ref.read(proposalRepositoryProvider);
    try {
      final updated = await repo.approveAndSend(proposalId);
      // Cập nhật state
      final current = state.value ?? [];
      state = AsyncData(
        current.map((p) => p.id == updated.id ? updated : p).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider lọc proposals theo status.
final pendingProposalsProvider = Provider<List<Proposal>>((ref) {
  final proposals = ref.watch(proposalProvider).value ?? [];
  return proposals
      .where((p) => p.status == ProposalStatus.draft ||
                     p.status == ProposalStatus.approved)
      .toList();
});

final sentProposalsProvider = Provider<List<Proposal>>((ref) {
  final proposals = ref.watch(proposalProvider).value ?? [];
  return proposals.where((p) => p.status == ProposalStatus.sent).toList();
});
