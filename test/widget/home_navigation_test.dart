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
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';

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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.deals,
                builder: (context, state) => const PipelinePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.clients,
                builder: (context, state) => const ClientsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.analytics,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
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
    testWidgets('renders the four SoloNavBar labels on home', (tester) async {
      await _pumpApp(tester);

      expect(find.text('Hôm nay'), findsOneWidget);
      expect(find.text('Pipeline'), findsOneWidget);
      expect(find.text('Dự án'), findsOneWidget);
      expect(find.text('Tôi'), findsOneWidget);
    });

    testWidgets('tapping Pipeline tab navigates to deals page', (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Pipeline'));
      await tester.pumpAndSettle();

      expect(find.byType(PipelinePage), findsOneWidget);
    });

    testWidgets('tapping the third tab navigates to its branch', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Dự án'));
      await tester.pumpAndSettle();

      expect(find.byType(ClientsPage), findsOneWidget);
    });

    testWidgets('tapping the fourth tab navigates to its branch', (
      tester,
    ) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Tôi'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('nav bar persists after switching branch', (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Dự án'));
      await tester.pumpAndSettle();

      // Bottom nav labels still visible on clients page
      // Use findsAtLeastNWidgets since AppBar title may duplicate a nav label
      expect(find.text('Hôm nay'), findsAtLeastNWidgets(1));
      expect(find.text('Pipeline'), findsAtLeastNWidgets(1));
      expect(find.text('Tôi'), findsAtLeastNWidgets(1));
      expect(find.byType(SoloNavBar), findsOneWidget);
    });

    testWidgets('Pipeline tab is active when on deals route', (tester) async {
      await _pumpApp(tester, initialLocation: RouteNames.deals);

      // Verify PipelinePage is showing (not HomePage)
      expect(find.byType(PipelinePage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('third tab is active when on its route', (tester) async {
      await _pumpApp(tester, initialLocation: RouteNames.clients);

      expect(find.byType(ClientsPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    // `index` của SoloNavBar phải bám theo nhánh đang mở. Trước đây mỗi màn
    // gốc tự đặt cứng index của mình và ba test màn (MÀN 02/04/11) kiểm điều
    // đó; giờ shell đặt một lần nên chỗ kiểm chuyển về đây.
    testWidgets('SoloNavBar index follows the active branch', (tester) async {
      await _pumpApp(tester);
      expect(tester.widget<SoloNavBar>(find.byType(SoloNavBar)).index, 0);

      await tester.tap(find.text('Pipeline'));
      await tester.pumpAndSettle();
      expect(tester.widget<SoloNavBar>(find.byType(SoloNavBar)).index, 1);

      await tester.tap(find.text('Tôi'));
      await tester.pumpAndSettle();
      expect(tester.widget<SoloNavBar>(find.byType(SoloNavBar)).index, 3);
    });

    testWidgets('tapping the first tab returns to home page', (tester) async {
      await _pumpApp(tester);

      // Navigate away first
      await tester.tap(find.text('Pipeline'));
      await tester.pumpAndSettle();
      expect(find.byType(PipelinePage), findsOneWidget);

      // Tap home tab
      await tester.tap(find.text('Hôm nay'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
