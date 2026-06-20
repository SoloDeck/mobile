import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/app/app_shell.dart';
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

GoRouter _createRouter({String initialLocation = RouteNames.home}) {
  // Mirror the production shell: StatefulShellRoute + SwipeableTabBody, with
  // branch order home / deals / clients / analytics matching AppShell's tab
  // indices.
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            SwipeableTabBody(
          navigationShell: navigationShell,
          children: children,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.deals,
              builder: (context, state) => const PipelinePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.clients,
              builder: (context, state) => const ClientsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.analytics,
              builder: (context, state) => const DashboardPage(),
            ),
          ]),
        ],
      ),
    ],
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  String initialLocation = RouteNames.home,
}) async {
  final router = _createRouter(initialLocation: initialLocation);
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
  group('bottom navigation bar', () {
    testWidgets('renders 4 tab labels on home', (tester) async {
      await _pumpApp(tester);

      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Pipeline'), findsOneWidget);
      expect(find.text('Khách hàng'), findsOneWidget);
      expect(find.text('Báo cáo'), findsOneWidget);
    });

    testWidgets('tapping Pipeline tab navigates to deals page', (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Pipeline'));
      await tester.pumpAndSettle();

      expect(find.byType(PipelinePage), findsOneWidget);
    });

    testWidgets('tapping Khách hàng tab navigates to clients page', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Khách hàng'));
      await tester.pumpAndSettle();

      expect(find.byType(ClientsPage), findsOneWidget);
    });

    testWidgets('tapping Báo cáo tab navigates to analytics page', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Báo cáo'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('bottom nav persists after navigating to clients', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Khách hàng'));
      await tester.pumpAndSettle();

      // Bottom nav labels still visible on clients page
      // Use findsAtLeastNWidgets since AppBar title may duplicate a nav label
      expect(find.text('Trang chủ'), findsAtLeastNWidgets(1));
      expect(find.text('Pipeline'), findsAtLeastNWidgets(1));
      expect(find.text('Báo cáo'), findsAtLeastNWidgets(1));
      expect(find.byType(BottomAppBar), findsOneWidget);
    });

    testWidgets('Pipeline tab is active when on deals route', (tester) async {
      await _pumpApp(tester, initialLocation: RouteNames.deals);

      // Verify PipelinePage is showing (not HomePage)
      expect(find.byType(PipelinePage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('Khách hàng tab is active when on clients route', (
      tester,
    ) async {
      await _pumpApp(tester, initialLocation: RouteNames.clients);

      expect(find.byType(ClientsPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('tapping Trang chủ tab returns to home page', (tester) async {
      await _pumpApp(tester);

      // Navigate away first
      await tester.tap(find.text('Pipeline'));
      await tester.pumpAndSettle();
      expect(find.byType(PipelinePage), findsOneWidget);

      // Tap home tab
      await tester.tap(find.text('Trang chủ'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
