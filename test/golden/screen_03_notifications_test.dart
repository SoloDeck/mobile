import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/notifications/presentation/pages/notifications_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';

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
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NotificationsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 03 — cấu trúc theo figcaption', () {
    testWidgets('có dải chip lọc theo loại, "Tất cả" đang chọn', (
      tester,
    ) async {
      await _pump(tester);

      final bar = tester.widget<FilterChipBar>(find.byType(FilterChipBar));
      expect(bar.labels, ['Tất cả', 'Tiền', 'Lead mới', 'Task']);
      expect(bar.selectedIndex, 0);
    });

    testWidgets(
      'không có thanh tab đáy — màn mở từ nút chuông, không phải mục gốc',
      (tester) async {
        await _pump(tester);
        expect(find.byType(SoloNavBar), findsNothing);
      },
    );

    testWidgets('appbar có nút quay lại', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<SoloAppBar>(find.byType(SoloAppBar)).leading,
        isNotNull,
      );
    });

    testWidgets('nút quay lại có nối hành động', (tester) async {
      await _pump(tester);
      final back = tester.widget<IconButtonBox>(
        find.byWidgetPredicate(
          (w) => w is IconButtonBox && w.label == 'Quay lại',
        ),
      );
      expect(back.onTap, isNotNull);
    });

    testWidgets(
      'mỗi thông báo viết đủ số liệu, không rút gọn thành xem chi tiết',
      (tester) async {
        await _pump(tester);
        expect(
          find.textContaining('12.500.000 ₫', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.text(
            'Bản nháp cho Việt Phát đã sẵn sàng, còn 2 biến chưa điền.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('mục Hôm qua mờ đi bằng Opacity, không bị lọc khỏi danh sách', (
      tester,
    ) async {
      await _pump(tester);

      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((o) => o.opacity == 0.62)
          .length;
      expect(opacities, 2);
      // Vẫn thấy được nội dung — không phải bị ẩn hay xoá khỏi cây widget.
      expect(find.text('Đã nhận 15.000.000 ₫'), findsOneWidget);
      expect(find.text('Task đến hạn hôm nay'), findsOneWidget);
    });
  });

  group('MÀN 03 — quy ước màu', () {
    testWidgets('chỉ thông báo tiền quá hạn được tô nền hồng', (tester) async {
      await _pump(tester);

      final tinted = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration! as BoxDecoration).color == AppColors.momoSoft,
          );
      expect(tinted.length, 1);
    });
  });

  group('MÀN 03 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Thông báo',
        'Tất cả',
        'Tiền',
        'Lead mới',
        'Task',
        'HÔM NAY',
        'Quá hạn thanh toán',
        '07:00',
        'Báo giá soạn xong',
        '08:42',
        'Bản nháp cho Việt Phát đã sẵn sàng, còn 2 biến chưa điền.',
        'HÔM QUA',
        'Đã nhận 15.000.000 ₫',
        '16:03',
        'Việt Phát chuyển khoản đợt 1. Hợp đồng chuyển sang Đang chạy.',
        'Task đến hạn hôm nay',
        '08:00',
        '“Gửi bản nháp logo vòng 2” — dự án Minh An.',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });
  });

  group('MÀN 03 — quy tắc không được vi phạm', () {
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

  testWidgets('ảnh vàng — màn 03 thông báo đẩy', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(NotificationsPage),
      matchesGoldenFile('goldens/screen_03_notifications.png'),
    );
  }, skip: !soloFontsLoaded);
}
