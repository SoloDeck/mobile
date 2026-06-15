import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/domain/repositories/analytics_repository.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/repository/analytics_repository_impl.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/pages/dashboard_page.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/domain/repositories/clients_repository.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/repository/clients_repository_impl.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/pipeline_page.dart';
import 'package:solodesk_mobile/modules/home/presentation/pages/home_page.dart';

class _FakeClientsRepository implements ClientsRepository {
  @override
  Future<List<Client>> listClients({
    ClientStatus? status,
    String? name,
    String? email,
  }) async => [];

  @override
  Future<Client> getClient(String id) => throw UnimplementedError();

  @override
  Future<Client> createClient({
    required String name,
    ClientType? type,
    String? email,
    String? phone,
    String? notes,
  }) => throw UnimplementedError();
}

class _FakeDealsRepository implements DealsRepository {
  @override
  Future<List<Deal>> listDeals({DealStage? stage}) async => [];

  @override
  Future<Deal> getDeal(String id) => throw UnimplementedError();

  @override
  Future<Deal> createDeal({
    required String clientId,
    required String title,
    DealSource? source,
    double? estimatedValue,
    String? currency,
    String? notes,
  }) => throw UnimplementedError();

  @override
  Future<Deal> transitionStage({
    required String id,
    required DealStage targetStage,
    String? note,
  }) => throw UnimplementedError();
}

class _FakeAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<DashboardSummary> getDashboard() async => const DashboardSummary(
    totalClients: 0,
    activeDeals: 0,
    totalRevenue: 0,
    pendingInvoices: 0,
  );
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.clients,
        builder: (context, state) => const ClientsPage(),
      ),
      GoRoute(
        path: RouteNames.deals,
        builder: (context, state) => const PipelinePage(),
      ),
      GoRoute(
        path: RouteNames.analytics,
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}

Future<void> _pumpApp(WidgetTester tester) async {
  final router = _createRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clientsRepositoryProvider.overrideWithValue(_FakeClientsRepository()),
        dealsRepositoryProvider.overrideWithValue(_FakeDealsRepository()),
        analyticsRepositoryProvider.overrideWithValue(
          _FakeAnalyticsRepository(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('navigates from Home to clients', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Khách hàng'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Khách hàng'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('navigates from Home to the deal pipeline', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Pipeline thương vụ'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Pipeline thương vụ'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('navigates from Home to analytics', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Tổng quan'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Tổng quan'),
      ),
      findsOneWidget,
    );
  });
}
