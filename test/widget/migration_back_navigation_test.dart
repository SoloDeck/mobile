import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/notifications/presentation/pages/notifications_page.dart';

/// Nút "Quay lại" của các màn migration thật sự pop được.
///
/// Mười hai màn đó dùng chung đúng một khuôn — `IconButtonBox(SoloIcons.back,
/// label: 'Quay lại', onTap: () => context.pop())` trong `SoloAppBar.leading`.
/// Từng file golden đã kiểm `onTap != null`; chỗ này kiểm cái mà assert kia
/// không kiểm được: gọi vào callback đó có pop thật hay không. Một màn đại diện
/// là đủ, vì khuôn giống hệt nhau — thêm màn nữa chỉ tốn thời gian chạy mà
/// không phủ thêm nhánh code nào.
void main() {
  testWidgets('bấm Quay lại trên màn migration thì pop về màn trước', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('màn gốc')),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    router.push('/notifications');
    await tester.pumpAndSettle();
    expect(find.text('màn gốc'), findsNothing);

    // bySemanticsLabel chứ không byType: MÀN 03 có hai IconButtonBox (quay lại
    // và "Đánh dấu tất cả đã đọc"), byType sẽ ném vì tìm được hai.
    await tester.tap(find.bySemanticsLabel('Quay lại'));
    await tester.pumpAndSettle();

    expect(find.text('màn gốc'), findsOneWidget);
    expect(router.state.matchedLocation, '/');
  });
}
