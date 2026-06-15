import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/domain/repositories/analytics_repository.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/repository/analytics_repository_impl.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/providers/analytics_provider.dart';

class _FakeAnalyticsRepository implements AnalyticsRepository {
  const _FakeAnalyticsRepository(this.summary);

  final DashboardSummary summary;

  @override
  Future<DashboardSummary> getDashboard() async => summary;
}

void main() {
  test('dashboardSummaryProvider exposes metrics from the repository', () async {
    const summary = DashboardSummary(
      totalClients: 12,
      activeDeals: 5,
      totalRevenue: 75000000,
      pendingInvoices: 3,
    );
    final container = ProviderContainer(
      overrides: [
        analyticsRepositoryProvider.overrideWithValue(
          const _FakeAnalyticsRepository(summary),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(dashboardSummaryProvider.future);

    expect(result.totalClients, 12);
    expect(result.activeDeals, 5);
    expect(result.totalRevenue, 75000000);
    expect(result.pendingInvoices, 3);
  });
}
