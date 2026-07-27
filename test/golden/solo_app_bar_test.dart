import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Align(alignment: Alignment.topCenter, child: child),
  ),
);

void main() {
  group('SoloAppBar — bố cục', () {
    testWidgets('mép nút quay lại thẳng hàng với lề nội dung 18', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const SoloAppBar(
            title: 'Thông báo',
            leading: IconButtonBox(
              SoloIcons.back,
              label: 'Quay lại',
              ghost: true,
            ),
          ),
        ),
      );

      // Hộp chạm bắt đầu ở 15, phần vẽ ra bắt đầu ở 15 + 3 = 18.
      final tapBox = tester.getTopLeft(find.byType(IconButtonBox));
      expect(tapBox.dx, AppGap.screen - IconButtonBox.overhang);
      expect(tapBox.dx + IconButtonBox.overhang, AppGap.screen);
    });

    testWidgets('không có nút icon thì lề trái đúng 18', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_host(const SoloAppBar(title: 'Pipeline')));
      expect(tester.getTopLeft(find.text('Pipeline')).dx, AppGap.screen);
    });

    testWidgets('tiêu đề dài bị cắt bằng ba chấm, không xuống dòng', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const SoloAppBar(
            title: 'Một cái tên dự án rất dài không thể vừa một dòng nào cả',
            titleSize: SoloAppBar.xxs,
          ),
        ),
      );

      final text = tester.widget<Text>(find.textContaining('Một cái tên'));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('mỗi hành động cách nhau đúng 12', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const SoloAppBar(
            title: 'Pipeline',
            actions: [
              IconButtonBox(SoloIcons.search, label: 'Tìm kiếm'),
              IconButtonBox(SoloIcons.tag, label: 'Lọc theo nhãn'),
            ],
          ),
        ),
      );

      final boxes = find.byType(IconButtonBox);
      final first = tester.getTopRight(boxes.at(0)).dx;
      final second = tester.getTopLeft(boxes.at(1)).dx;
      expect(second - first, AppGap.lg);
    });
  });

  group('SoloAppBar — tiêu đề', () {
    testWidgets('năm cỡ đều dùng được và giãn cách theo đúng cỡ', (
      tester,
    ) async {
      const sizes = [
        SoloAppBar.lg,
        SoloAppBar.md,
        SoloAppBar.sm,
        SoloAppBar.xs,
        SoloAppBar.xxs,
      ];

      for (final size in sizes) {
        await tester.pumpWidget(
          _host(SoloAppBar(title: 'Doanh thu', titleSize: size)),
        );
        final style = tester.widget<Text>(find.text('Doanh thu')).style!;
        expect(style.fontSize, size);
        expect(style.letterSpacing, size * -0.02);
      }
    });

    testWidgets('dòng ngày tháng đứng trên tiêu đề', (tester) async {
      await tester.pumpWidget(
        _host(
          const SoloAppBar(
            title: 'Hôm nay',
            overline: 'Thứ Bảy, 25/07',
            titleSize: SoloAppBar.md,
          ),
        ),
      );

      expect(find.text('Thứ Bảy, 25/07'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Thứ Bảy, 25/07')).dy,
        lessThan(tester.getTopLeft(find.text('Hôm nay')).dy),
      );
      expect(
        tester.widget<Text>(find.text('Thứ Bảy, 25/07')).style!.fontSize,
        AppText.overline.fontSize,
      );
    });

    testWidgets('nền tối đảo màu cả tiêu đề lẫn dòng phụ', (tester) async {
      await tester.pumpWidget(
        _host(
          const SoloAppBar(title: 'Ghi nhanh', overline: 'Lead', onDark: true),
        ),
      );

      expect(
        tester.widget<Text>(find.text('Ghi nhanh')).style!.color,
        AppColors.surface,
      );
      expect(
        tester.widget<Text>(find.text('Lead')).style!.color,
        AppColors.line,
      );
    });
  });

  testWidgets('ảnh vàng — bốn kiểu thanh tiêu đề của bản phác thảo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MÀN 04
            SoloAppBar(
              title: 'Pipeline',
              actions: [
                IconButtonBox(SoloIcons.search, label: 'Tìm kiếm'),
                IconButtonBox(SoloIcons.tag, label: 'Lọc theo nhãn'),
              ],
            ),
            // MÀN 03
            SoloAppBar(
              title: 'Thông báo',
              leading: IconButtonBox(
                SoloIcons.back,
                label: 'Quay lại',
                ghost: true,
              ),
              actions: [
                IconButtonBox(
                  SoloIcons.check,
                  label: 'Đánh dấu đã đọc',
                  ghost: true,
                ),
              ],
            ),
            // MÀN 09
            SoloAppBar(
              title: 'Nhận diện Minh An',
              overline: 'Dự án',
              titleSize: SoloAppBar.sm,
              leading: IconButtonBox(
                SoloIcons.back,
                label: 'Quay lại',
                ghost: true,
              ),
              actions: [IconButtonBox(SoloIcons.dots, label: 'Thêm lựa chọn')],
            ),
            // MÀN 11
            SoloAppBar(
              title: 'Doanh thu',
              actions: [StatusChip('2026', trailingIcon: SoloIcons.chevron)],
            ),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/solo_app_bar.png'),
    );
  }, skip: !soloFontsLoaded);
}
