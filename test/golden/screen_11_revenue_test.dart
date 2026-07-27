import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/domain/repositories/analytics_repository.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/repository/analytics_repository_impl.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/pages/revenue_page.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';

import '../flutter_test_config.dart';

/// `totalRevenue` là field duy nhất của `DashboardSummary` mà MÀN 11 dùng —
/// đúng bằng số tiền đã thu của bản phác thảo (`284.500.000 ₫`) để các assert
/// chuỗi hiển thị bên dưới không đổi so với trước khi nối provider.
class _FakeAnalyticsRepository implements AnalyticsRepository {
  const _FakeAnalyticsRepository(this.summary);

  final DashboardSummary summary;

  @override
  Future<DashboardSummary> getDashboard() async => summary;
}

const _summary = DashboardSummary(
  totalClients: 12,
  activeDeals: 5,
  totalRevenue: 284500000,
  pendingInvoices: 3,
);

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsRepositoryProvider.overrideWithValue(
          const _FakeAnalyticsRepository(_summary),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RevenuePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 11 — cấu trúc theo figcaption', () {
    testWidgets('tấm phiếu tiền đã thu nằm trên cùng thân màn', (tester) async {
      await _pump(tester);

      final slipTop = tester.getTopLeft(find.byType(SlipCard)).dy;
      final statCardTop = tester.getTopLeft(find.byType(Card).first).dy;
      expect(slipTop, lessThan(statCardTop));
    });

    testWidgets('chỉ đúng hai chỉ số phụ, không thành báo cáo', (tester) async {
      await _pump(tester);

      // Nhãn đi qua `SectionLabel` nên tự in hoa — assert đúng dạng hiển thị.
      expect(find.text('TỈ LỆ CHỐT'), findsOneWidget);
      expect(find.text('DEAL TRUNG BÌNH'), findsOneWidget);
      // Hai `Card` chỉ số phụ + một `Card` công nợ theo tuổi nợ = 3.
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('biểu đồ cột có đủ 7 tháng, tháng 07 là tháng hiện tại', (
      tester,
    ) async {
      await _pump(tester);

      for (final month in ['01', '02', '03', '04', '05', '06', '07']) {
        expect(find.text(month), findsOneWidget, reason: 'thiếu tháng $month');
      }
    });

    testWidgets('công nợ theo tuổi nợ có đủ ba mốc', (tester) async {
      await _pump(tester);

      expect(find.text('Trong hạn'), findsOneWidget);
      expect(find.text('Quá 1–7 ngày'), findsOneWidget);
      expect(find.text('Quá trên 30 ngày'), findsOneWidget);
    });

    // Thanh tab không còn nằm trong màn này: `AppShell` dựng một
    // `SoloNavBar` chung cho cả bốn màn gốc và tự đặt `index` theo nhánh
    // đang mở. Việc mục "Tôi" sáng đúng lúc giờ kiểm ở
    // `test/widget/home_navigation_test.dart`.
  });

  group('MÀN 11 — quy ước màu', () {
    testWidgets('tiền đã thu là số tham chiếu, mực chứ không phải ngọc', (
      tester,
    ) async {
      await _pump(tester);

      // HTML dòng 915: `.num` của tổng đã thu không khai màu, nên nó thừa
      // hưởng `--ink` — Tone.neutral, không phải Tone.ok. Doc comment của
      // `Money` gọi đích danh MÀN 11 ở mục Tone.neutral.
      final hero = tester.widget<Money>(find.byType(Money).first);
      expect(hero.tone, Tone.neutral);
    });

    testWidgets('công nợ càng để lâu màu càng gắt', (tester) async {
      await _pump(tester);

      final moneyWidgets = tester
          .widgetList<Money>(find.byType(Money))
          .toList();
      // Thứ tự dựng: tiền đã thu (neutral), rồi ba hàng công nợ theo tuổi nợ
      // (neutral → warn → money).
      expect(moneyWidgets[1].tone, Tone.neutral);
      expect(moneyWidgets[2].tone, Tone.warn);
      expect(moneyWidgets[3].tone, Tone.money);
    });

    testWidgets('chỉ một tấm phiếu răng cưa, và nó là tiền đã thu', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SlipCard), findsOneWidget);
    });

    testWidgets('biểu đồ cột dùng họ hồng, không dùng tím của AI', (
      tester,
    ) async {
      await _pump(tester);

      // Chỉ tìm trong SlipCard: ProgressBar của công nợ cũng dùng DecoratedBox
      // và cũng có thể mang màu momo (nhóm "quá trên 30 ngày") — không liên
      // quan tới biểu đồ cột, quét cả cây sẽ đếm sai.
      final decorations = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(SlipCard),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((w) => (w.decoration as BoxDecoration).color)
          .toList();

      // Bảy cột: sáu cột nhạt momoSoft, một cột hiện tại momo đặc.
      expect(decorations.where((c) => c == AppColors.momoSoft).length, 6);
      expect(decorations.where((c) => c == AppColors.momo).length, 1);
      expect(decorations, isNot(contains(AppColors.aiSoft)));
      expect(decorations, isNot(contains(AppColors.momoLine)));
    });

    testWidgets('có đường xé giữa khối số tiền và biểu đồ', (tester) async {
      await _pump(tester);
      expect(find.byType(PerforatedDivider), findsOneWidget);
    });
  });

  group('MÀN 11 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Doanh thu',
        '2026',
        // Bốn chuỗi dưới đi qua `SectionLabel`/`SectionHeader` nên hiển thị
        // IN HOA — chép nguyên văn dạng hiển thị thật, không phải dạng gõ
        // trong `_MockData`.
        'ĐÃ THU · 7 THÁNG ĐẦU NĂM',
        '↑ 22% so với 2025',
        '17 hợp đồng',
        'TỈ LỆ CHỐT',
        '41%',
        '17/41 báo giá',
        'DEAL TRUNG BÌNH',
        '16,7 tr',
        '↑ 1,9 tr',
        'CÔNG NỢ THEO TUỔI NỢ',
        'Chi tiết',
        'Trong hạn',
        'Quá 1–7 ngày',
        'Quá trên 30 ngày',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });

    testWidgets('số tiền định dạng theo cách người Việt viết', (tester) async {
      await _pump(tester);

      // "Đã thu" đi qua `dashboardSummaryProvider.totalRevenue` — giá trị lấy
      // từ `_summary` ở đầu file, không còn là hằng số tại chỗ.
      expect(find.text('284.500.000 ₫'), findsOneWidget);
      expect(find.text('19.000.000 ₫'), findsOneWidget);
      expect(find.text('7.500.000 ₫'), findsOneWidget);
      expect(find.text('5.000.000 ₫'), findsOneWidget);
    });
  });

  group('MÀN 11 — quy tắc không được vi phạm', () {
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

  testWidgets('ảnh vàng — màn 11 doanh thu', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(RevenuePage),
      matchesGoldenFile('goldens/screen_11_revenue.png'),
    );
  }, skip: !soloFontsLoaded);
}
