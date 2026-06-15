import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/pipeline_summary.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/shared/utils/currency_formatter.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Pipeline overview — one summary card per stage showing the deal count and the
/// total value sitting in that stage.
class PipelinePage extends ConsumerWidget {
  const PipelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipeline = ref.watch(dealPipelineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pipeline thương vụ')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dealListProvider.future),
        child: AsyncValueWidget<List<StageSummary>>(
          value: pipeline,
          onRetry: () => ref.invalidate(dealListProvider),
          data: (summaries) {
            final totalDeals = summaries.fold<int>(0, (s, e) => s + e.count);
            if (totalDeals == 0) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Chưa có thương vụ nào')),
                ],
              );
            }
            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final summary in summaries)
                  StageSummaryCard(summary: summary),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StageSummaryCard extends StatelessWidget {
  const StageSummaryCard({super.key, required this.summary});

  final StageSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.push(RouteNames.deals),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                summary.stage.label,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${summary.count}',
                    style: theme.textTheme.headlineMedium,
                  ),
                  Text(
                    formatVnd(summary.totalValue),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
