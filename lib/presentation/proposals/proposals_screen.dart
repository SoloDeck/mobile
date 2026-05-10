import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/core/widgets/loading_shimmer.dart';
import 'package:mobile/domain/providers/proposal_provider.dart';
import 'package:mobile/presentation/proposals/widgets/proposal_card.dart';

/// Màn hình quản lý Proposals — duyệt và gửi nhanh.
class ProposalsScreen extends ConsumerStatefulWidget {
  const ProposalsScreen({super.key});

  @override
  ConsumerState<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends ConsumerState<ProposalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _sendingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleApproveAndSend(String proposalId) async {
    setState(() => _sendingId = proposalId);

    final success =
        await ref.read(proposalProvider.notifier).approveAndSend(proposalId);

    if (!mounted) return;

    setState(() => _sendingId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã duyệt và gửi thành công!'
              : 'Gửi thất bại. Vui lòng thử lại.',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proposalsAsync = ref.watch(proposalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đã gửi'),
          ],
        ),
      ),
      body: proposalsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (error, _) => ErrorRetryWidget(
          message: error.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.invalidate(proposalProvider),
        ),
        data: (_) => TabBarView(
          controller: _tabController,
          children: [
            _buildPendingTab(),
            _buildSentTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab() {
    final pending = ref.watch(pendingProposalsProvider);

    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 56,
                color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text('Không có đề xuất nào chờ duyệt'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(proposalProvider),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: pending.length,
        itemBuilder: (_, index) {
          final proposal = pending[index];
          return ProposalCard(
            proposal: proposal,
            isSending: _sendingId == proposal.id,
            onApproveAndSend: () => _handleApproveAndSend(proposal.id),
          );
        },
      ),
    );
  }

  Widget _buildSentTab() {
    final sent = ref.watch(sentProposalsProvider);

    if (sent.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.outbox_outlined, size: 56,
                color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text('Chưa gửi đề xuất nào'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: sent.length,
      itemBuilder: (_, index) {
        return ProposalCard(
          proposal: sent[index],
          onApproveAndSend: () {}, // already sent
        );
      },
    );
  }
}
