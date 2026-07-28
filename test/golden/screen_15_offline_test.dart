import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/home/presentation/pages/home_offline_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';
import '../support/fake_settings_repository.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeOfflinePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 15 — cấu trúc theo figcaption', () {
    testWidgets('dải báo ngoại tuyến nằm trên cùng, trước thanh tiêu đề', (
      tester,
    ) async {
      await _pump(tester);

      final bannerTop = tester
          .getTopLeft(find.text('Đang ngoại tuyến · dữ liệu lúc 08:14'))
          .dy;
      final appBarTop = tester.getTopLeft(find.byType(SoloAppBar)).dy;
      final slipTop = tester.getTopLeft(find.byType(SlipCard)).dy;

      expect(bannerTop, lessThan(appBarTop));
      expect(appBarTop, lessThan(slipTop));
    });

    testWidgets(
      'app không chặn thao tác: ba mục vẫn được ghi nhận, chỉ xếp hàng chờ',
      (tester) async {
        await _pump(tester);

        // Lead ghi bằng giọng nói, hai task tick xong, một ảnh bàn giao — cả
        // ba đều đã "làm được", chỉ khác là mỗi cái có một chip điều kiện gửi
        // thay vì gửi thẳng.
        expect(find.text('Lead ghi bằng giọng nói'), findsOneWidget);
        expect(find.text('Đánh dấu 2 task đã xong'), findsOneWidget);
        expect(find.text('1 ảnh bàn giao'), findsOneWidget);
        expect(find.byType(StatusChip), findsNWidgets(4));
      },
    );

    testWidgets('không có vòng xoay vô hạn nào thay cho hàng chờ', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });

    testWidgets('tờ phiếu công nợ là số liệu cũ (xám hoá)', (tester) async {
      await _pump(tester);
      expect(tester.widget<SlipCard>(find.byType(SlipCard)).stale, isTrue);
    });

    testWidgets('nút ghi nhanh ở thanh tab báo mất mạng', (tester) async {
      await _pump(tester);
      final navBar = tester.widget<SoloNavBar>(find.byType(SoloNavBar));
      expect(navBar.offline, isTrue);
      expect(navBar.index, 0);
    });

    // Màn này nằm ngoài `StatefulShellRoute` nên `AppShell` không cấp thanh tab
    // hộ nó — nếu hai callback dưới đây rỗng thì đây là màn duy nhất trong app
    // không có lối ra nào ngoài vuốt mép trái.
    testWidgets('thanh tab và nút ghi nhanh có nối hành động', (tester) async {
      await _pump(tester);
      final navBar = tester.widget<SoloNavBar>(find.byType(SoloNavBar));
      expect(navBar.onSelect, isNotNull);
      expect(navBar.onQuickCapture, isNotNull);
    });
  });

  group('MÀN 15 — quy ước màu', () {
    testWidgets('mỗi chip hàng chờ đúng tone của điều kiện gửi', (
      tester,
    ) async {
      await _pump(tester);

      final chips = <String, Tone>{
        for (final chip in tester.widgetList<StatusChip>(
          find.byType(StatusChip),
        ))
          chip.label: chip.tone,
      };

      expect(chips['Số cũ'], Tone.neutral);
      expect(chips['Chờ AI'], Tone.ai);
      expect(chips['Đã lưu máy'], Tone.neutral);
      expect(chips['Chờ Wi-Fi'], Tone.neutral);
    });

    testWidgets('chỉ thẻ lead ghi âm có vạch tím chờ AI xử lý', (tester) async {
      await _pump(tester);
      final accentCards = tester.widgetList<AccentCard>(
        find.byType(AccentCard),
      );
      expect(accentCards.map((c) => c.tone), [Tone.ai]);
    });

    testWidgets('con số công nợ vẫn giữ ngữ nghĩa tiền phải đòi', (
      tester,
    ) async {
      await _pump(tester);
      expect(tester.widget<Money>(find.byType(Money)).tone, Tone.money);
    });

    testWidgets('chỉ một tấm phiếu răng cưa, và nó là tiền', (tester) async {
      await _pump(tester);
      expect(find.byType(SlipCard), findsOneWidget);
    });
  });

  group('MÀN 15 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Đang ngoại tuyến · dữ liệu lúc 08:14',
        '3 chờ gửi',
        'Hôm nay',
        'Thứ Bảy, 25/07',
        // Đi qua SectionLabel, tự .toUpperCase() (xem lib/ui/section_label.dart).
        'ĐANG CHỜ THU · THÁNG 7',
        'Số cũ',
        '31.500.000 ₫',
        'Sẽ cập nhật lại khi có mạng',
        // Nhãn của SectionHeader cũng đi qua SectionLabel, tự in hoa.
        'HÀNG CHỜ ĐỒNG BỘ',
        'Thử lại',
        'Lead ghi bằng giọng nói',
        '“Anh Nam Studio Cỏ, 40 sản phẩm…”',
        'Chờ AI',
        'Đánh dấu 2 task đã xong',
        'Dự án Minh An',
        'Đã lưu máy',
        '1 ảnh bàn giao',
        '2,1 MB · tải lên khi có Wi-Fi',
        'Chờ Wi-Fi',
        'Chưa gửi được tin nhắn nào',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }

      expect(
        find.text(
          'Nhắc thanh toán và báo giá chỉ gửi đi\n'
          'sau khi máy kết nối lại mạng.',
        ),
        findsOneWidget,
      );
    });
  });

  group('MÀN 15 — quy tắc không được vi phạm', () {
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

    testWidgets('lead ghi bằng giọng nói không có nút gửi thẳng', (
      tester,
    ) async {
      await _pump(tester);
      // Quy tắc 5: AI không tự gửi. Ở đây còn mất mạng nên càng không có nút
      // hành động nào trên thẻ hàng chờ — chỉ có chip báo trạng thái.
      expect(find.text('Gửi nhắc qua Zalo'), findsNothing);
      expect(find.text('Duyệt và gửi'), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 15 ngoại tuyến', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(HomeOfflinePage),
      matchesGoldenFile('goldens/screen_15_offline.png'),
    );
  }, skip: !soloFontsLoaded);
}
