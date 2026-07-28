import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/presentation/controllers/proposals_list_controller.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/error_retry_widget.dart';
import 'package:solodesk_mobile/shared/widgets/loading_shimmer.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// "Báo giá chờ duyệt" — danh sách báo giá đã gửi khách và đang chờ khách
/// phản hồi (`ProposalStatus.sent`). Chạm vào một dòng mở MÀN 08 để xem lại
/// chi tiết báo giá đó.
class ProposalsPendingListPage extends ConsumerStatefulWidget {
  const ProposalsPendingListPage({super.key});

  @override
  ConsumerState<ProposalsPendingListPage> createState() =>
      _ProposalsPendingListPageState();
}

class _ProposalsPendingListPageState
    extends ConsumerState<ProposalsPendingListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      ref.read(proposalsListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proposalsListControllerProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        appBar: AppBar(title: const Text('Báo giá chờ duyệt')),
        body: state.when(
          loading: () => const LoadingShimmer(),
          error: (error, _) => ErrorRetryWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(proposalsListControllerProvider),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () =>
                ref.read(proposalsListControllerProvider.notifier).refresh(),
            child: data.items.isEmpty
                ? _EmptyState(scrollController: _scrollController)
                : _ProposalList(
                    scrollController: _scrollController,
                    state: data,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProposalList extends StatelessWidget {
  const _ProposalList({required this.scrollController, required this.state});

  final ScrollController scrollController;
  final ProposalListState state;

  @override
  Widget build(BuildContext context) {
    final showFooter = state.isLoadingMore;
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.items.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final proposal = state.items[index];
        return _ProposalCard(
          proposal: proposal,
          onTap: () =>
              context.push(RouteNames.proposalReviewOf(proposal.id)),
        );
      },
    );
  }
}

/// One row in the pending-approval list — display number, joined deal's
/// client name and the quoted total, with the status shown as an icon-led
/// badge (mirrors `InvoiceCard`'s layout).
///
/// The client name comes from `dealDetailProvider(proposal.dealId)` — `N+1`
/// per-item watches, accepted here since there is no batch deal-join helper
/// yet. Each card resolves its own deal independently so a slow/failed lookup
/// only degrades that one row, never the whole list.
class _ProposalCard extends ConsumerWidget {
  const _ProposalCard({required this.proposal, required this.onTap});

  final Proposal proposal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = proposal.status;
    final total = proposal.content.total;
    final dealState = ref.watch(dealDetailProvider(proposal.dealId));

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: status.tone.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SoloIcon(
                    status.icon,
                    label: status.label,
                    size: SoloIcon.md,
                    color: status.tone.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.displayNumber,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _ClientLine(dealState: dealState),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (total != null) Money.card(total, tone: Tone.neutral),
                  const SizedBox(height: 8),
                  StatusChip(status.label, tone: status.tone, icon: status.icon),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The joined deal's client name — a subtle loading/fallback placeholder
/// while `dealDetailProvider` resolves, so one slow lookup never blocks the
/// rest of the list from rendering.
class _ClientLine extends StatelessWidget {
  const _ClientLine({required this.dealState});

  final AsyncValue<Deal> dealState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final text = dealState.when(
      data: (deal) => deal.clientName ?? 'Chưa gắn khách hàng',
      loading: () => 'Đang tải khách hàng…',
      error: (_, _) => 'Chưa gắn khách hàng',
    );
    return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

/// Ngữ nghĩa màu + icon của một trạng thái báo giá, dùng cho ô icon dẫn đầu
/// và chip trạng thái ở cuối dòng trong [_ProposalCard].
extension _ProposalStatusVisual on ProposalStatus {
  Tone get tone => switch (this) {
    ProposalStatus.draft => Tone.neutral,
    ProposalStatus.sent => Tone.neutral,
    ProposalStatus.accepted => Tone.ok,
    ProposalStatus.rejected => Tone.money,
    ProposalStatus.expired => Tone.warn,
    ProposalStatus.superseded => Tone.neutral,
  };

  SoloIconData get icon => switch (this) {
    ProposalStatus.draft => SoloIcons.file,
    ProposalStatus.sent => SoloIcons.send,
    ProposalStatus.accepted => SoloIcons.check,
    ProposalStatus.rejected => SoloIcons.dots,
    ProposalStatus.expired => SoloIcons.clock,
    ProposalStatus.superseded => SoloIcons.dots,
  };
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      controller: scrollController,
      children: [
        const SizedBox(height: AppGap.navBarInset),
        Icon(
          Icons.request_quote_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Hiện chưa có báo giá nào',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Báo giá đã gửi và đang chờ khách phản hồi sẽ hiện ở đây.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
