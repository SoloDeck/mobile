import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/login_landing_page.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';

import '../flutter_test_config.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const LoginLandingPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 01 — cấu trúc theo figcaption', () {
    testWidgets('thẻ "Lần đăng nhập gần nhất" bấm được — nhớ một chạm', (
      tester,
    ) async {
      await _pump(tester);

      expect(
        find.ancestor(
          of: find.text('Hoàng Lan'),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
    });

    testWidgets('nút Google đứng trên, nút email đứng dưới', (tester) async {
      await _pump(tester);

      final googleTop = tester
          .getTopLeft(find.widgetWithText(FilledButton, 'Tiếp tục với Google'))
          .dy;
      final emailTop = tester
          .getTopLeft(
            find.widgetWithText(OutlinedButton, 'Đăng nhập bằng email'),
          )
          .dy;
      expect(googleTop, lessThan(emailTop));
    });

    testWidgets('nút Google là nút đặc, nút email là nút viền', (tester) async {
      await _pump(tester);

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('không có SoloNavBar và không có dải hành động nổi', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(SoloNavBar), findsNothing);
      expect(find.byType(BottomActionBar), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('MÀN 01 — quy ước màu', () {
    testWidgets('không có tấm phiếu răng cưa nào — nội dung không phải tiền', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byIcon(Icons.receipt), findsNothing);
    });

    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });
  });

  group('MÀN 01 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Chào bạn.\nViệc hôm nay\nđợi sẵn rồi.',
        'Đăng nhập để đồng bộ pipeline, hợp đồng và lịch nhắc thu tiền giữa '
            'máy tính và điện thoại.',
        'LẦN ĐĂNG NHẬP GẦN NHẤT',
        'Hoàng Lan',
        'lan.design@gmail.com',
        'Tiếp tục với Google',
        'Đăng nhập bằng email',
        'Tiếp tục nghĩa là bạn đồng ý với Điều khoản\n'
            'và Chính sách bảo mật của SoloDesk.',
      ]) {
        expect(find.text(text), findsOneWidget, reason: 'thiếu chuỗi "$text"');
      }
    });

    testWidgets('câu chào nói về việc, không nhắc tên sản phẩm', (
      tester,
    ) async {
      await _pump(tester);
      // "SoloDesk" chỉ xuất hiện ở dòng điều khoản cuối màn, không ở câu chào.
      final headline = tester.widget<Text>(
        find.text('Chào bạn.\nViệc hôm nay\nđợi sẵn rồi.'),
      );
      expect(headline.data, isNot(contains('SoloDesk')));
    });
  });

  group('MÀN 01 — quy tắc không được vi phạm', () {
    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });

    testWidgets('không có khung máy mockup — không .sbar, không .homebar', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('9:41'), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 01 đăng nhập', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(LoginLandingPage),
      matchesGoldenFile('goldens/screen_01_login.png'),
    );
  }, skip: !soloFontsLoaded);
}
