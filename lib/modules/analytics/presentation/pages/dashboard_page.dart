import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/providers/analytics_provider.dart';
import 'package:solodesk_mobile/shared/utils/currency_formatter.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Analytics dashboard — headline workspace totals from `/analytics/dashboard`.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardSummaryProvider.future),
        child: AsyncValueWidget<DashboardSummary>(
          value: summary,
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
          data: (s) => GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              MetricCard(
                label: 'Khách hàng',
                value: '${s.totalClients}',
                icon: Icons.people_outline,
              ),
              MetricCard(
                label: 'Thương vụ đang chạy',
                value: '${s.activeDeals}',
                icon: Icons.trending_up,
              ),
              MetricCard(
                label: 'Doanh thu',
                value: formatVnd(s.totalRevenue),
                icon: Icons.payments_outlined,
              ),
              MetricCard(
                label: 'Hóa đơn chờ',
                value: '${s.pendingInvoices}',
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
