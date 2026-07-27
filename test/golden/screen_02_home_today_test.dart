import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/providers/analytics_provider.dart';
import 'package:solodesk_mobile/modules/home/presentation/pages/home_page_new.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';

import '../flutter_test_config.dart';

/// Tổng dashboard giả cho golden test — `pendingInvoices: 3` khớp đúng
/// con dấu "3 hoá đơn" chép nguyên văn từ bản phác thảo. Các field khác không
/// được MÀN 02 dùng tới nên giá trị chỉ cần hợp lệ.
const _summary = DashboardSummary(
  totalClients: 12,
  activeDeals: 5,
  totalRevenue: 48000000,
  pendingInvoices: 3,
);

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardSummaryProvider.overrideWith((ref) async => _summary),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeTodayPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 02 — cấu trúc theo figcaption', () {
    testWidgets('tờ phiếu công nợ nằm trên cùng thân màn', (tester) async {
      await _pump(tester);

      final slipTop = tester.getTopLeft(find.byType(SlipCard)).dy;
      final firstCardTop = tester.getTopLeft(find.byType(AccentCard).first).dy;
      expect(slipTop, lessThan(firstCardTop));
    });

    testWidgets('ba việc xếp theo mức thiệt hại: tiền, AI, trễ hạn', (
      tester,
    ) async {
      await _pump(tester);

      final tones = tester
          .widgetList<AccentCard>(find.byType(AccentCard))
          .map((c) => c.tone)
          .toList();
      expect(tones, [Tone.money, Tone.ai, Tone.warn]);
    });

    testWidgets('mỗi việc cần hành động có nút ngay trên thẻ', (tester) async {
      await _pump(tester);

      expect(find.text('Gửi nhắc qua Zalo'), findsOneWidget);
      expect(find.text('Xem và duyệt'), findsOneWidget);
      expect(find.text('Hoãn'), findsOneWidget);
    });

    // Thanh tab không còn nằm trong màn này: `AppShell` dựng một
    // `SoloNavBar` chung cho cả bốn màn gốc và tự đặt `index` theo nhánh
    // đang mở. Việc mục "Hôm nay" sáng đúng lúc giờ kiểm ở
    // `test/widget/home_navigation_test.dart`.
  });

  group('MÀN 02 — quy ước màu', () {
    testWidgets('công nợ là hồng, đã thu là ngọc', (tester) async {
      await _pump(tester);

      final hero = tester.widget<Money>(find.byType(Money));
      expect(hero.tone, Tone.money);

      expect(
        find.textContaining('48.000.000 ₫', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('con dấu quá hạn dùng tone tiền', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<StampBadge>(find.byType(StampBadge)).tone,
        Tone.money,
      );
    });

    testWidgets('chỉ một tấm phiếu răng cưa, và nó là tiền', (tester) async {
      await _pump(tester);
      // Lead mới và task trễ hạn dùng Card / AccentCard, không phải SlipCard.
      expect(find.byType(SlipCard), findsOneWidget);
    });
  });

  group('MÀN 02 — dữ liệu nối provider', () {
    testWidgets('con dấu hoá đơn chờ lấy đúng pendingInvoices từ provider', (
      tester,
    ) async {
      await _pump(tester);
      expect(
        tester.widget<StampBadge>(find.byType(StampBadge)).text,
        '${_summary.pendingInvoices} hoá đơn',
      );
    });
  });

  group('MÀN 02 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Hôm nay',
        'Thứ Bảy, 25/07',
        'ĐANG CHỜ THU · THÁNG 7',
        'CẦN BẠN XỬ LÝ',
        '3 việc',
        'Nhắc thanh toán · Minh An',
        'Đợt 2 quá hạn 6 ngày · 12.500.000 ₫',
        'Báo giá đã soạn xong',
        'Landing page — Cty Việt Phát · chờ bạn duyệt',
        '2 task trễ hạn',
        'Dự án Nhận diện Minh An',
        'LEAD MỚI TỪ FORM',
        'Trần Nam · Studio Cỏ',
        'Chụp sản phẩm · vừa gửi 22 phút trước',
      ]) {
        // findsWidgets chứ không phải findsOneWidget: “Hôm nay” xuất hiện đúng
        // hai lần trong bản phác thảo — tiêu đề màn và nhãn tab.
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });

    testWidgets('số tiền định dạng theo cách người Việt viết', (tester) async {
      await _pump(tester);
      expect(find.text('31.500.000 ₫'), findsOneWidget);
    });
  });

  group('MÀN 02 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 02 hôm nay', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(HomeTodayPage),
      matchesGoldenFile('goldens/screen_02_home_today.png'),
    );
  }, skip: !soloFontsLoaded);
}
