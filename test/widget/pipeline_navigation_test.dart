import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/pipeline_page_new.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';

/// Thẻ lead ở MÀN 04 (Pipeline) là lối đi bằng ngón tay sang MÀN 05 (chi tiết
/// thương vụ).
///
/// `test/golden/screen_04_pipeline_test.dart` dựng `PipelinePage` trong một
/// `MaterialApp` **không có router**, nên nó không thể kiểm được việc chạm thẻ
/// dẫn đi đâu — nó chỉ chốt hình dáng. Chỗ này lo phần còn lại: dựng một
/// `GoRouter` thật hai route và kiểm đường dẫn sau khi chạm.
///
/// Route đích ở đây là một `Scaffold` giả hiện thẳng `id` bắt được, chứ không
/// phải `DealDetailPage` thật — cái cần kiểm là *điều hướng tới đúng id*, dựng
/// màn thật chỉ kéo thêm `dealsRepositoryProvider`/`invoicesRepositoryProvider`
/// vào cho test dễ vỡ vì lý do không liên quan.

/// Hai deal cố định — đủ để phân biệt "chạm thẻ nào thì mở đúng deal đó".
final _deals = [
  Deal(
    id: 'd1',
    ownerUserId: 'u1',
    clientId: 'c1',
    title: 'Chụp 40 sản phẩm',
    stage: DealStage.newLead,
    createdAt: DateTime.now(),
    clientName: 'Trần Nam',
    estimatedValue: 15000000,
  ),
  Deal(
    id: 'd2',
    ownerUserId: 'u1',
    clientId: 'c2',
    title: 'Landing page ra mắt',
    stage: DealStage.qualified,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    clientName: 'Cty Việt Phát',
    estimatedValue: 28000000,
  ),
];

/// Dựng màn trong một router thật và trả về router đó để assert đường dẫn.
///
/// Chỉ override `dealListProvider` — cách gọn nhất và cũng là cách
/// `test/golden/screen_04_pipeline_test.dart` đang dùng. `dealPipelineProvider`
/// tự suy ra số đếm từng giai đoạn từ chính danh sách này nên không cần chạm
/// tới `dealsRepositoryProvider`.
Future<GoRouter> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/deals',
    routes: [
      GoRoute(
        path: '/deals',
        builder: (context, state) => const PipelinePage(),
      ),
      GoRoute(
        path: '/deals/:id',
        builder: (context, state) =>
            Scaffold(body: Text(state.pathParameters['id']!)),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [dealListProvider.overrideWith((ref) async => _deals)],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return router;
}

void main() {
  testWidgets('chạm thẻ lead đầu tiên thì mở chi tiết đúng deal đó', (
    tester,
  ) async {
    final router = await _pump(tester);
    expect(router.state.matchedLocation, '/deals');

    // Tìm theo tên deal chứ không phải `find.byType(Card).first`: thứ tự thẻ
    // do provider quyết, tên deal buộc test phải nói rõ nó đang chạm cái nào.
    await tester.tap(
      find.ancestor(
        of: find.text('Chụp 40 sản phẩm'),
        matching: find.byType(Card),
      ),
    );
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/deals/d1');
    expect(find.text('d1'), findsOneWidget);
  });

  testWidgets('mỗi thẻ mang id riêng — thẻ thứ hai không mở deal thứ nhất', (
    tester,
  ) async {
    final router = await _pump(tester);

    // Pipeline lọc theo MỘT giai đoạn tại một thời điểm (mặc định giai đoạn
    // đầu, "Khách mới" — xem `_PipelinePageState._selectedStageIndex` trong
    // `pipeline_page_new.dart`), nên thẻ deal thứ hai (giai đoạn "Đã sàng lọc")
    // chưa hiện cho tới khi chạm đúng chip giai đoạn của nó.
    await tester.tap(find.textContaining('Đã sàng lọc'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.ancestor(
        of: find.text('Landing page ra mắt'),
        matching: find.byType(Card),
      ),
    );
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/deals/d2');
  });
}
