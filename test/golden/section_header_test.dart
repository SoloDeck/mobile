import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/section_header.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppGap.screen),
        child: child,
      ),
    ),
  ),
);

void main() {
  group('SectionHeader', () {
    testWidgets('nhãn in hoa, liên kết giữ nguyên kiểu viết', (tester) async {
      await tester.pumpWidget(
        _host(const SectionHeader('Cần bạn xử lý', actionLabel: '3 việc')),
      );

      expect(find.text('CẦN BẠN XỬ LÝ'), findsOneWidget);
      expect(find.text('3 việc'), findsOneWidget);
    });

    testWidgets('liên kết dùng màu tím vì đây là lối đi tiếp', (tester) async {
      await tester.pumpWidget(
        _host(const SectionHeader('Công nợ', actionLabel: 'Chi tiết')),
      );
      expect(
        tester.widget<Text>(find.text('Chi tiết')).style!.color,
        AppColors.ai,
      );
    });

    testWidgets('không có actionLabel thì mép phải trống hẳn', (tester) async {
      await tester.pumpWidget(_host(const SectionHeader('Giọng văn')));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('bấm liên kết gọi đúng callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          SectionHeader(
            'Hàng chờ đồng bộ',
            actionLabel: 'Thử lại',
            onAction: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Thử lại'));
      expect(taps, 1);
    });

    testWidgets('khoảng cách trên dưới nằm sẵn trong widget', (tester) async {
      await tester.pumpWidget(_host(const SectionHeader('Lead mới từ form')));

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(SectionHeader),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        padding.padding,
        const EdgeInsets.only(
          top: AppGap.sectionTop,
          bottom: AppGap.sectionBottom,
        ),
      );
    });

    testWidgets('nhãn dài không đẩy liên kết ra khỏi màn', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const SectionHeader(
            'Một cái nhãn mục dài bất thường để thử tràn dòng',
            actionLabel: 'Tất cả',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getTopRight(find.text('Tất cả')).dx,
        lessThanOrEqualTo(390 - AppGap.screen),
      );
    });
  });

  testWidgets('ảnh vàng — ba kiểu nhãn mục', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionHeader('Cần bạn xử lý', actionLabel: '3 việc'),
            SectionHeader('Công nợ theo tuổi nợ', actionLabel: 'Chi tiết'),
            SectionHeader('Giọng văn'),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/section_header.png'),
    );
  }, skip: !soloFontsLoaded);
}
