import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/domain/repositories/analytics_repository.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/repository/analytics_repository_impl.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/pages/dashboard_page.dart';

class _FakeAnalyticsRepository implements AnalyticsRepository {
  const _FakeAnalyticsRepository(this.summary);

  final DashboardSummary summary;

  @override
  Future<DashboardSummary> getDashboard() async => summary;
}

void main() {
  testWidgets('DashboardPage renders the headline metrics', (tester) async {
    const summary = DashboardSummary(
      totalClients: 12,
      activeDeals: 5,
      totalRevenue: 2000000,
      pendingInvoices: 3,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsRepositoryProvider.overrideWithValue(
            const _FakeAnalyticsRepository(summary),
          ),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Khách hàng'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Thương vụ đang chạy'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Hóa đơn chờ'), findsOneWidget);
  });
}
