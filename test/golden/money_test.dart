import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';

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
  group('Money.format — cách người Việt viết số tiền', () {
    test('chấm ngăn nghìn, ký hiệu ₫ đứng sau', () {
      expect(Money.format(31500000), '31.500.000 ₫');
      expect(Money.format(12500000), '12.500.000 ₫');
      expect(Money.format(149000), '149.000 ₫');
    });

    test('số nhỏ hơn một nghìn không có dấu chấm nào', () {
      expect(Money.format(0), '0 ₫');
      expect(Money.format(999), '999 ₫');
      expect(Money.format(1000), '1.000 ₫');
    });

    test('số âm giữ dấu trừ ở đầu', () {
      expect(Money.format(-2500000), '-2.500.000 ₫');
    });

    test('làm tròn về đồng, không để lẻ thập phân', () {
      expect(Money.format(1500.4), '1.500 ₫');
      expect(Money.format(1500.6), '1.501 ₫');
    });
  });

  group('Money — màu mang nghĩa', () {
    testWidgets('tiền phải đòi là hồng', (tester) async {
      await tester.pumpWidget(_host(const Money(12500000)));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.color,
        AppColors.momo,
      );
    });

    testWidgets('tiền đã thu là ngọc', (tester) async {
      await tester.pumpWidget(_host(const Money(48000000, tone: Tone.ok)));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.color,
        AppColors.jade,
      );
    });

    testWidgets('số tiền tham chiếu là mực chính, không phải hồng', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const Money(25000000, tone: Tone.neutral)));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.color,
        AppColors.ink,
      );
    });

    testWidgets('số tiền trung tính không rơi vào màu mờ của thanh tiến độ', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const Money(284500000, tone: Tone.neutral)),
      );
      expect(
        tester.widget<Text>(find.byType(Text)).style!.color,
        isNot(AppColors.ink3),
      );
    });
  });

  group('Money — ba cỡ', () {
    testWidgets('inline, card và hero lấy đúng ba cỡ chữ', (tester) async {
      await tester.pumpWidget(_host(const Money.inline(1)));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.fontSize,
        AppText.num.fontSize,
      );

      await tester.pumpWidget(_host(const Money.card(1)));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.fontSize,
        AppText.numMd.fontSize,
      );

      await tester.pumpWidget(_host(const Money.hero(1)));
      expect(
        tester.widget<Text>(find.byType(Text)).style!.fontSize,
        AppText.numHero.fontSize,
      );
    });
  });

  group('MonoText — số không phải tiền', () {
    testWidgets('dùng chữ mono và chữ số đều cột', (tester) async {
      await tester.pumpWidget(_host(const MonoText('7/11 việc')));
      final style = tester.widget<Text>(find.byType(Text)).style!;

      expect(style.fontFamily, AppFontFamily.mono);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    testWidgets('giữ nguyên chuỗi truyền vào, không tự định dạng lại', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const MonoText('~15.000.000 ₫')));
      expect(find.text('~15.000.000 ₫'), findsOneWidget);
    });
  });

  testWidgets(
    'ảnh vàng — ba cỡ tiền, ba tone, và số không phải tiền',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 260));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Money.hero(31500000),
              SizedBox(height: AppGap.md),
              Money.card(7500000),
              SizedBox(height: AppGap.md),
              Money.inline(48000000, tone: Tone.ok),
              SizedBox(height: AppGap.md),
              Money.card(25000000, tone: Tone.neutral),
              SizedBox(height: AppGap.md),
              MonoText('~15.000.000 ₫'),
              SizedBox(height: AppGap.md),
              MonoText('7/11 việc'),
              SizedBox(height: AppGap.md),
              MonoText('1,8 / 10 GB'),
            ],
          ),
        ),
      );

      await expectLater(
        find.byType(Column),
        matchesGoldenFile('goldens/money.png'),
      );
    },
    skip: !soloFontsLoaded,
  );
}
