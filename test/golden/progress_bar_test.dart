import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';

Widget _host(Widget child, {double width = 300}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

double _fillFactor(WidgetTester tester) => tester
    .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
    .widthFactor!;

void main() {
  group('ProgressBar — tỉ lệ', () {
    testWidgets('phần đầy đúng bằng value', (tester) async {
      await tester.pumpWidget(_host(const ProgressBar(value: 0.64)));
      expect(_fillFactor(tester), closeTo(0.64, 0.0001));
    });

    testWidgets('phần đầy có chiều cao thật, không co về 0', (tester) async {
      await tester.pumpWidget(
        _host(const ProgressBar(value: 0.5, height: ProgressBar.thick)),
      );

      final fill = tester.getSize(find.byType(FractionallySizedBox));
      expect(fill.height, ProgressBar.thick);
      expect(fill.width, closeTo(150, 0.5));
    });

    testWidgets('value ngoài khoảng 0–1 bị kẹp lại thay vì tràn', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const ProgressBar(value: 1.8)));
      expect(_fillFactor(tester), 1.0);

      await tester.pumpWidget(_host(const ProgressBar(value: -0.5)));
      expect(_fillFactor(tester), 0.0);
    });
  });

  group('ProgressBar — hình thức', () {
    testWidgets('hai chiều cao của bản phác thảo', (tester) async {
      await tester.pumpWidget(_host(const ProgressBar(value: 0.5)));
      expect(
        tester.getSize(find.byType(ProgressBar)).height,
        ProgressBar.standard,
      );

      await tester.pumpWidget(
        _host(const ProgressBar(value: 0.5, height: ProgressBar.thick)),
      );
      expect(
        tester.getSize(find.byType(ProgressBar)).height,
        ProgressBar.thick,
      );
    });

    testWidgets('màu nền rãnh là màu đường kẻ', (tester) async {
      await tester.pumpWidget(_host(const ProgressBar(value: 0.5)));
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox).last).color,
        AppColors.line,
      );
    });

    testWidgets('nhận màu đặc theo ngữ nghĩa', (tester) async {
      await tester.pumpWidget(
        _host(const ProgressBar(value: 0.22, color: AppColors.ai)),
      );

      final decoration =
          tester.widget<DecoratedBox>(find.byType(DecoratedBox).last).decoration
              as BoxDecoration;
      expect(decoration.color, AppColors.ai);
      expect(decoration.gradient, isNull);
    });

    testWidgets('gradient thắng màu đặc, dùng cho thanh tiến độ dự án', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const ProgressBar(
            value: 0.64,
            height: ProgressBar.thick,
            gradient: LinearGradient(colors: [AppColors.ai, AppColors.momo]),
          ),
        ),
      );

      final decoration =
          tester.widget<DecoratedBox>(find.byType(DecoratedBox).last).decoration
              as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.color, isNull);
    });
  });

  // Không có chữ nên chụp được ngay.
  testWidgets('ảnh vàng — bốn thanh của bản phác thảo', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProgressBar(value: 0.34, color: AppColors.stage2),
            SizedBox(height: AppGap.lg),
            ProgressBar(
              value: 0.64,
              height: ProgressBar.thick,
              gradient: LinearGradient(colors: [AppColors.ai, AppColors.momo]),
            ),
            SizedBox(height: AppGap.lg),
            ProgressBar(value: 0.24, color: AppColors.amber),
            SizedBox(height: AppGap.lg),
            ProgressBar(value: 0.16, color: AppColors.momo),
          ],
        ),
        width: 240,
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/progress_bar.png'),
    );
  });
}
