import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/core/widgets/loading_shimmer.dart';
import 'package:mobile/domain/providers/auth_provider.dart';
import 'package:mobile/domain/providers/deal_provider.dart';
import 'package:mobile/domain/providers/pipeline_provider.dart';
import 'package:mobile/presentation/pipeline/widgets/deal_list_tile.dart';
import 'package:mobile/presentation/pipeline/widgets/stage_summary_card.dart';

/// Màn hình tổng quan Pipeline.
class PipelineScreen extends ConsumerWidget {
  const PipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelineAsync = ref.watch(pipelineStagesProvider);
    final dealsAsync = ref.watch(dealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pipeline'),
        actions: [
          // ── User avatar / logout ──
          _buildUserMenu(context, ref),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dealsProvider);
          ref.invalidate(pipelineStagesProvider);
        },
        child: pipelineAsync.when(
          loading: () => const LoadingShimmer(),
          error: (error, _) => ErrorRetryWidget(
            message: error.toString().replaceAll('Exception: ', ''),
            onRetry: () {
              ref.invalidate(dealsProvider);
              ref.invalidate(pipelineStagesProvider);
            },
          ),
          data: (stages) => _buildContent(context, ref, stages, dealsAsync),
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            user?.fullName.isNotEmpty == true
                ? user!.fullName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
              SizedBox(width: 8),
              Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          ref.read(authProvider.notifier).logout();
        }
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List stages,
    AsyncValue dealsAsync,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Stage summary cards (horizontal scroll) ──
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Tổng quan giai đoạn',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stages.length,
                  itemBuilder: (_, index) {
                    return StageSummaryCard(stage: stages[index]);
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Section header: Recent deals ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Text(
                  'Deals gần đây',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  dealsAsync.whenOrNull(
                        data: (deals) => '${deals.length} deals',
                      ) ??
                      '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        // ── Deal list ──
        dealsAsync.when(
          loading: () => const SliverFillRemaining(
            child: LoadingShimmer(itemCount: 3),
          ),
          error: (error, _) => SliverFillRemaining(
            child: ErrorRetryWidget(
              message: error.toString().replaceAll('Exception: ', ''),
              onRetry: () => ref.invalidate(dealsProvider),
            ),
          ),
          data: (deals) {
            if (deals.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Text('Chưa có deal nào.'),
                ),
              );
            }

            final sorted = List.of(deals)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverList.builder(
                itemCount: sorted.length,
                itemBuilder: (_, index) {
                  return DealListTile(deal: sorted[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
