import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/pipeline_page_new.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/stage_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';
import '../support/fake_settings_repository.dart';

/// Mốc giờ cố định để suy ra `createdAt` — "Vào N ngày trước" trên mỗi thẻ
/// được `PipelinePage` tính bằng `DateTime.now().difference(...)`, nên chỉ cần
/// mốc này không lệch ngày với thời điểm build của test (chênh nhau vài mili
/// giây, không đáng lo).
final _now = DateTime.now();

/// Bốn deal đang hoạt động (khớp bốn giai đoạn đầu) + một deal đã mất, để
/// kiểm tra `lost` bị loại khỏi `FilterChipBar`/`StageBar` nhưng vẫn có mặt
/// trong danh sách thẻ bên dưới (`dealListProvider` không lọc theo giai đoạn).
final _deals = [
  Deal(
    id: 'd1',
    ownerUserId: 'u1',
    clientId: 'c1',
    title: 'Chụp 40 sản phẩm',
    stage: DealStage.newLead,
    createdAt: _now,
    clientName: 'Trần Nam',
    estimatedValue: 15000000,
  ),
  Deal(
    id: 'd2',
    ownerUserId: 'u1',
    clientId: 'c2',
    title: 'Landing page ra mắt',
    stage: DealStage.qualified,
    createdAt: _now.subtract(const Duration(days: 2)),
    clientName: 'Cty Việt Phát',
    estimatedValue: 28000000,
  ),
  Deal(
    id: 'd3',
    ownerUserId: 'u1',
    clientId: 'c3',
    title: 'Bộ ảnh menu quán',
    stage: DealStage.proposalSent,
    createdAt: _now.subtract(const Duration(days: 5)),
    clientName: 'Hải Phong Coffee',
    estimatedValue: 9000000,
  ),
  Deal(
    id: 'd4',
    ownerUserId: 'u1',
    clientId: 'c4',
    title: 'Sửa 3 banner',
    stage: DealStage.inNegotiation,
    createdAt: _now.subtract(const Duration(days: 11)),
    clientName: 'Ngọc Linh Shop',
    estimatedValue: 2000000,
  ),
  Deal(
    id: 'd5',
    ownerUserId: 'u1',
    clientId: 'c5',
    title: 'In name card',
    stage: DealStage.lost,
    createdAt: _now.subtract(const Duration(days: 3)),
    clientName: 'Khách cũ',
    estimatedValue: 5000000,
  ),
];

/// Bốn deal cùng một giai đoạn (`newLead`, chọn sẵn mặc định) + một deal đã
/// mất, dùng riêng cho các bài kiểm chuỗi hiển thị/heat-cycle bên dưới: pipeline
/// chỉ hiện MỘT giai đoạn tại một thời điểm (xem `_deals` ở trên), nên để thấy
/// cả bốn kiểu heat mock (`_heatFor` lặp theo `index % 4`) cùng lúc mà không
/// phải chạm chip, cả bốn phải chung một giai đoạn.
final _headlineDeals = [
  Deal(
    id: 'h1',
    ownerUserId: 'u1',
    clientId: 'c1',
    title: 'Chụp 40 sản phẩm',
    stage: DealStage.newLead,
    createdAt: _now,
    clientName: 'Trần Nam',
    estimatedValue: 15000000,
  ),
  Deal(
    id: 'h2',
    ownerUserId: 'u1',
    clientId: 'c2',
    title: 'Landing page ra mắt',
    stage: DealStage.newLead,
    createdAt: _now.subtract(const Duration(days: 2)),
    clientName: 'Cty Việt Phát',
    estimatedValue: 28000000,
  ),
  Deal(
    id: 'h3',
    ownerUserId: 'u1',
    clientId: 'c3',
    title: 'Bộ ảnh menu quán',
    stage: DealStage.newLead,
    createdAt: _now.subtract(const Duration(days: 5)),
    clientName: 'Hải Phong Coffee',
    estimatedValue: 9000000,
  ),
  Deal(
    id: 'h4',
    ownerUserId: 'u1',
    clientId: 'c4',
    title: 'Sửa 3 banner',
    stage: DealStage.newLead,
    createdAt: _now.subtract(const Duration(days: 11)),
    clientName: 'Ngọc Linh Shop',
    estimatedValue: 2000000,
  ),
  Deal(
    id: 'h5',
    ownerUserId: 'u1',
    clientId: 'c5',
    title: 'In name card',
    stage: DealStage.lost,
    createdAt: _now.subtract(const Duration(days: 3)),
    clientName: 'Khách cũ',
    estimatedValue: 5000000,
  ),
];

Future<void> _pump(WidgetTester tester, {List<Deal>? deals}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dealListProvider.overrideWith((ref) async => deals ?? _deals),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const PipelinePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 04 — cấu trúc theo figcaption', () {
    testWidgets('sáu giai đoạn thành dải chip cuộn ngang, không phải cột', (
      tester,
    ) async {
      await _pump(tester);

      final bar = tester.widget<FilterChipBar>(find.byType(FilterChipBar));
      expect(bar.labels.length, StageBar.stageCount);
      expect(bar.selectedIndex, 0);
    });

    testWidgets(
      'thanh màu dưới chip vẽ hình dáng pipeline theo tỉ trọng, loại giai đoạn đã mất',
      (tester) async {
        await _pump(tester);

        final stageBar = tester.widget<StageBar>(find.byType(StageBar));
        // newLead=1, qualified=1, proposalSent=1, inNegotiation=1, active=0,
        // completedAndBilled=0 — deal `lost` (d5) không được tính vào đây.
        expect(stageBar.weights, [1, 1, 1, 1, 0, 0]);
        // Dạng proportional, không phải dạng steps của MÀN 05.
        expect(stageBar.filledSteps, isNull);
      },
    );

    testWidgets('giá trị ước tính hiện ngay trên mỗi thẻ deal', (tester) async {
      await _pump(tester);

      // Pipeline hiện đúng MỘT giai đoạn tại một thời điểm — mặc định giai
      // đoạn đầu (`newLead`) đã chọn sẵn nên d1 hiện ngay; các giai đoạn còn
      // lại cần chạm đúng chip của nó mới hiện thẻ tương ứng.
      expect(find.text('~15.000.000 ₫'), findsOneWidget); // d1 — newLead

      await tester.ensureVisible(find.textContaining(DealStage.qualified.label));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(DealStage.qualified.label));
      await tester.pumpAndSettle();
      expect(find.text('~28.000.000 ₫'), findsOneWidget); // d2 — qualified

      await tester.ensureVisible(find.textContaining(DealStage.proposalSent.label));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(DealStage.proposalSent.label));
      await tester.pumpAndSettle();
      expect(find.text('~9.000.000 ₫'), findsOneWidget); // d3 — proposalSent

      await tester.ensureVisible(find.textContaining(DealStage.inNegotiation.label));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(DealStage.inNegotiation.label));
      await tester.pumpAndSettle();
      expect(find.text('~2.000.000 ₫'), findsOneWidget); // d4 — inNegotiation

      // d5 là deal đã mất — `lost` không có chip riêng nên deal đã mất không
      // còn hiện trong pipeline đang chạy ở bất kỳ giai đoạn nào.
      expect(find.text('~5.000.000 ₫'), findsNothing);
    });

    // Thanh tab không còn nằm trong màn này: `AppShell` dựng một
    // `SoloNavBar` chung cho cả bốn màn gốc và tự đặt `index` theo nhánh
    // đang mở. Việc mục "Pipeline" sáng đúng lúc giờ kiểm ở
    // `test/widget/home_navigation_test.dart`.

    testWidgets(
      'mỗi thẻ nêu số ngày kể từ khi deal được tạo, lấy từ createdAt',
      (tester) async {
        await _pump(tester);

        // Cùng lý do như bài kiểm giá trị ước tính ở trên: mỗi giai đoạn hiện
        // riêng, nên phải lần lượt chọn từng chip mới thấy hết bốn thẻ.
        expect(find.text('Vào 0 ngày trước'), findsOneWidget); // d1

        await tester.ensureVisible(find.textContaining(DealStage.qualified.label));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining(DealStage.qualified.label));
        await tester.pumpAndSettle();
        expect(find.text('Vào 2 ngày trước'), findsOneWidget); // d2

        await tester.ensureVisible(find.textContaining(DealStage.proposalSent.label));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining(DealStage.proposalSent.label));
        await tester.pumpAndSettle();
        expect(find.text('Vào 5 ngày trước'), findsOneWidget); // d3

        await tester.ensureVisible(find.textContaining(DealStage.inNegotiation.label));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining(DealStage.inNegotiation.label));
        await tester.pumpAndSettle();
        expect(find.text('Vào 11 ngày trước'), findsOneWidget); // d4
      },
    );
  });

  group('MÀN 04 — quy ước màu', () {
    testWidgets('tổng ước tính pipeline tô hồng như bản phác thảo', (
      tester,
    ) async {
      await _pump(tester);
      final total = tester.widget<Money>(find.byType(Money));
      expect(total.tone, Tone.money);
    });

    testWidgets(
      'chip "Chưa chấm" là tím vì chờ AI chấm điểm, không phải hồng',
      (tester) async {
        await _pump(tester);
        // d1 — duy nhất thẻ hiện ở giai đoạn mặc định (`newLead`) — rơi vào
        // chu kỳ mock "chưa chấm" (`index % 4 == 0`).
        final chip = tester
            .widgetList<StatusChip>(
              find.ancestor(
                of: find.text('Chưa chấm'),
                matching: find.byType(StatusChip),
              ),
            )
            .first;
        expect(chip.tone, Tone.ai);
      },
    );

    testWidgets('avatar deal ở tông "Nguội" dùng tone trung tính', (
      tester,
    ) async {
      // `_heatFor` lặp theo vị trí trong danh sách ĐANG LỌC — cần bốn deal
      // cùng giai đoạn để vị trí thứ tư (Nguội) thật sự rơi vào deal "NL"
      // (`_headlineDeals`, xem doc-comment ở khai báo), thay vì luôn rơi về
      // vị trí 0 ("Chưa chấm") như khi mỗi giai đoạn chỉ lọc còn một thẻ.
      await _pump(tester, deals: _headlineDeals);

      final avatar = tester.widget<Avatar>(
        find.ancestor(of: find.text('NL'), matching: find.byType(Avatar)),
      );
      expect(avatar.tone, Tone.neutral);
    });
  });

  group('MÀN 04 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester, deals: _headlineDeals);

      for (final text in [
        'Pipeline',
        'Chụp 40 sản phẩm',
        'Trần Nam',
        'Landing page ra mắt',
        'Cty Việt Phát',
        'Bộ ảnh menu quán',
        'Hải Phong Coffee',
        'Sửa 3 banner',
        'Ngọc Linh Shop',
        'Chưa chấm',
        '🔥 Hot',
        'Ấm',
        'Nguội',
      ]) {
        // findsWidgets chứ không phải findsOneWidget: "Pipeline" xuất hiện cả
        // ở tiêu đề màn lẫn nhãn tab dưới đáy.
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }

      // h5 là deal đã mất — không có chip "lost" nên nó không hiện trong
      // danh sách thẻ ở bất kỳ giai đoạn nào.
      expect(find.text('In name card'), findsNothing);
      expect(find.text('Khách cũ'), findsNothing);
    });

    testWidgets('tổng ước tính định dạng theo cách người Việt viết', (
      tester,
    ) async {
      await _pump(tester, deals: _headlineDeals);
      // 15tr + 28tr + 9tr + 2tr = 54tr — bốn deal đang hoạt động cùng ở giai
      // đoạn mặc định (`newLead`); deal đã mất (h5) không được tính vào đây.
      expect(find.text('54.000.000 ₫'), findsOneWidget);
      // `SectionLabel` tự in hoa (`text-transform: uppercase`), nên chuỗi
      // hiển thị viết hoa dù mã nguồn truyền vào viết thường.
      expect(find.text('4 LEAD · TỔNG ƯỚC TÍNH'), findsOneWidget);
    });
  });

  group('MÀN 04 — dữ liệu nối provider', () {
    testWidgets(
      'nhãn chip lọc giai đoạn ghép từ nhãn giai đoạn thật và số đếm thật',
      (tester) async {
        await _pump(tester);
        final bar = tester.widget<FilterChipBar>(find.byType(FilterChipBar));
        expect(bar.labels[0], '${DealStage.newLead.label} · 1');
        expect(bar.labels[3], '${DealStage.inNegotiation.label} · 1');
      },
    );

    testWidgets('trạng thái rỗng khi dealListProvider trả về danh sách rỗng', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dealListProvider.overrideWith((ref) async => const []),
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: PipelinePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Chưa có thương vụ nào trong pipeline.'),
        findsOneWidget,
      );
    });
  });

  group('MÀN 04 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có thành phần kéo thả nào — đổi giai đoạn bằng chip', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 04 pipeline', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(PipelinePage),
      matchesGoldenFile('goldens/screen_04_pipeline.png'),
    );
  }, skip: !soloFontsLoaded);
}
