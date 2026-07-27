import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child, {double width = 320}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.xl),
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

void main() {
  group('SlipCard — hình dáng', () {
    testWidgets('vết cắt ăn vào thân thẻ 8pt mỗi bên', (tester) async {
      // Tâm lệch ra ngoài 1, bán kính 9 → chiều sâu vết cắt là 8.
      expect(SlipCard.notchRadius, 9);
      expect(SlipCard.notchRadius - 1, 8);
    });

    testWidgets('notch dời được và làm thẻ vẽ lại', (tester) async {
      await tester.pumpWidget(
        _host(const SlipCard(notch: 52, child: SizedBox(height: 80))),
      );
      final first = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(SlipCard),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter!;

      await tester.pumpWidget(
        _host(const SlipCard(notch: 110, child: SizedBox(height: 80))),
      );
      final second = tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(SlipCard),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .painter!;

      expect(second.shouldRepaint(first), isTrue);
    });

    testWidgets('padding mặc định đúng 15 của bản phác thảo', (tester) async {
      await tester.pumpWidget(
        _host(const SlipCard(child: SizedBox(height: 40, width: 40))),
      );

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(SlipCard),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, const EdgeInsets.all(AppGap.slip));
    });
  });

  group('SlipCard — biến thể', () {
    testWidgets('mặc định không xám hoá', (tester) async {
      await tester.pumpWidget(
        _host(const SlipCard(child: SizedBox(height: 40))),
      );
      expect(find.byType(ColorFiltered), findsNothing);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('stale thì xám hoá và mờ đi cho số liệu cũ', (tester) async {
      await tester.pumpWidget(
        _host(const SlipCard(stale: true, child: SizedBox(height: 40))),
      );

      expect(find.byType(ColorFiltered), findsOneWidget);
      expect(
        tester.widget<Opacity>(find.byType(Opacity)).opacity,
        closeTo(0.72, 0.001),
      );
    });

    testWidgets('nhận viền đậm và nền chuyển sắc cho màn gói dịch vụ', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SlipCard(
            notch: 150,
            borderColor: AppColors.ai,
            borderWidth: 2,
            gradient: LinearGradient(
              colors: [AppColors.aiSoft, AppColors.surface],
            ),
            child: SizedBox(height: 60),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SlipCard), findsOneWidget);
    });
  });

  testWidgets('ảnh vàng — tấm phiếu công nợ của MÀN 02', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 220));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const SlipCard(
          notch: 88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionLabel('Đang chờ thu · tháng 7'),
                  StatusChip('3 hoá đơn', tone: Tone.money),
                ],
              ),
              SizedBox(height: AppGap.sm),
              Money.hero(31500000),
              SizedBox(height: AppGap.md),
              Row(
                children: [
                  StatusChip('1 sắp đến hạn', tone: Tone.warn),
                  SizedBox(width: AppGap.xs),
                  StatusChip('2 quá hạn', tone: Tone.money),
                ],
              ),
              PerforatedDivider(),
              Money.inline(48000000, tone: Tone.ok),
            ],
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(SlipCard),
      matchesGoldenFile('goldens/slip_card.png'),
    );
  }, skip: !soloFontsLoaded);

  // Hình dáng vết cắt không phụ thuộc font nên chụp được ngay.
  testWidgets('ảnh vàng — hình dáng vết cắt, thường và xám hoá', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SlipCard(notch: 40, child: SizedBox(height: 80, width: 200)),
            SizedBox(height: AppGap.lg),
            SlipCard(
              notch: 40,
              stale: true,
              borderColor: AppColors.momoLine,
              child: SizedBox(height: 80, width: 200),
            ),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/slip_card_shape.png'),
    );
  });
}
