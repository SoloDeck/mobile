import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/section_label.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Padding(padding: const EdgeInsets.all(AppGap.xl), child: child),
  ),
);

void main() {
  group('SectionLabel', () {
    testWidgets('in hoa chữ truyền vào, giữ nguyên dấu tiếng Việt', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const SectionLabel('Đang chờ thu · tháng 7')),
      );
      expect(find.text('ĐANG CHỜ THU · THÁNG 7'), findsOneWidget);
    });

    testWidgets('dùng chữ mono giãn cách 0.14em ở cỡ 10', (tester) async {
      await tester.pumpWidget(_host(const SectionLabel('Lịch thanh toán')));
      final style = tester.widget<Text>(find.byType(Text)).style!;

      expect(style.fontFamily, AppFontFamily.mono);
      expect(style.fontSize, 10);
      expect(style.letterSpacing, 1.4);
      expect(style.color, AppColors.ink3);
    });

    testWidgets('đổi được màu khi nhãn nằm trên nền tối', (tester) async {
      await tester.pumpWidget(
        _host(const SectionLabel('Đang chép lời', color: AppColors.surface)),
      );
      expect(
        tester.widget<Text>(find.byType(Text)).style!.color,
        AppColors.surface,
      );
    });
  });

  testWidgets('ảnh vàng — nhãn thường và nhãn đổi màu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionLabel('Đang chờ thu · tháng 7'),
            SizedBox(height: AppGap.lg),
            SectionLabel('Hàng chờ đồng bộ'),
            SizedBox(height: AppGap.lg),
            SectionLabel('Đang chép lời', color: AppColors.ai),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/section_label.png'),
    );
  }, skip: !soloFontsLoaded);
}
