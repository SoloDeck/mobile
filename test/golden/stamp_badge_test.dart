import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Center(
      child: Padding(padding: const EdgeInsets.all(AppGap.xxl), child: child),
    ),
  ),
);

void main() {
  group('StampBadge — ba dạng', () {
    testWidgets('due hồng, paid ngọc, draft tím', (tester) async {
      const expected = {
        Tone.money: AppColors.momo,
        Tone.ok: AppColors.jade,
        Tone.ai: AppColors.ai,
      };

      for (final entry in expected.entries) {
        await tester.pumpWidget(_host(StampBadge('Thử', tone: entry.key)));

        final decoration =
            tester.widget<Container>(find.byType(Container)).decoration!
                as BoxDecoration;
        expect(decoration.border!.top.color, entry.value);
        expect(decoration.border!.top.width, 2);
        expect(
          tester.widget<Text>(find.byType(Text)).style!.color,
          entry.value,
        );
      }
    });

    testWidgets('ba constructor đặt sẵn đúng tone', (tester) async {
      await tester.pumpWidget(_host(const StampBadge.due('Quá hạn 6 ngày')));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.color,
        AppColors.momo,
      );

      await tester.pumpWidget(_host(const StampBadge.paid('Đã thu')));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.color,
        AppColors.jade,
      );

      await tester.pumpWidget(_host(const StampBadge.draft('Bản nháp')));
      expect(tester.widget<Text>(find.byType(Text)).style!.color, AppColors.ai);
    });
  });

  group('StampBadge — hình thức con dấu', () {
    testWidgets('in hoa chữ truyền vào', (tester) async {
      await tester.pumpWidget(_host(const StampBadge.due('Quá hạn 6 ngày')));
      expect(find.text('QUÁ HẠN 6 NGÀY'), findsOneWidget);
    });

    testWidgets('nghiêng đúng 7 độ ngược chiều kim đồng hồ', (tester) async {
      await tester.pumpWidget(_host(const StampBadge.due('Quá hạn')));

      final rotate = tester.widget<Transform>(find.byType(Transform));
      // Ma trận xoay: phần tử [0][0] là cos của góc.
      expect(
        rotate.transform.storage[0],
        closeTo(math.cos(-7 * math.pi / 180), 0.0001),
      );
    });

    testWidgets('mờ nhẹ như mực dấu in trên giấy', (tester) async {
      await tester.pumpWidget(_host(const StampBadge.due('Quá hạn')));
      expect(
        tester.widget<Opacity>(find.byType(Opacity)).opacity,
        closeTo(0.92, 0.0001),
      );
    });

    testWidgets('không xuống dòng', (tester) async {
      await tester.pumpWidget(_host(const StampBadge.due('Quá hạn 6 ngày')));
      expect(tester.widget<Text>(find.byType(Text)).softWrap, isFalse);
    });
  });

  testWidgets('ảnh vàng — ba con dấu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StampBadge.due('Quá hạn 6 ngày'),
            SizedBox(width: AppGap.xl),
            StampBadge.paid('Đã thu'),
            SizedBox(width: AppGap.xl),
            StampBadge.draft('Bản nháp'),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Row),
      matchesGoldenFile('goldens/stamp_badge.png'),
    );
  }, skip: !soloFontsLoaded);
}
