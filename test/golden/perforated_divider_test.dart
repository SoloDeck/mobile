import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';

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

void main() {
  group('PerforatedDivider — bố cục', () {
    testWidgets('chiếm đúng chiều cao nét cộng lề trên dưới', (tester) async {
      await tester.pumpWidget(_host(const PerforatedDivider()));

      final size = tester.getSize(find.byType(PerforatedDivider));
      expect(size.height, 1.5 + AppGap.lg * 2);
    });

    testWidgets('nét vẽ tràn ra hai bên đúng bằng bleed', (tester) async {
      await tester.pumpWidget(
        _host(const PerforatedDivider(bleed: AppGap.slip)),
      );

      final painted = tester.getSize(find.byType(CustomPaint).last);
      expect(painted.width, 300 + AppGap.slip * 2);
    });

    testWidgets('bleed = 0 thì nét vừa đúng bề ngang ô chứa', (tester) async {
      await tester.pumpWidget(_host(const PerforatedDivider(bleed: 0)));

      final painted = tester.getSize(find.byType(CustomPaint).last);
      expect(painted.width, 300);
    });

    testWidgets('dùng được trong Card, không chỉ trong SlipCard', (
      tester,
    ) async {
      // MÀN 05 và MÀN 08 đặt đường xé trong Card thường.
      await tester.pumpWidget(
        _host(
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppGap.card),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Giá trị hợp đồng'),
                  PerforatedDivider(bleed: AppGap.card),
                  Text('25.000.000 ₫'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(PerforatedDivider), findsOneWidget);
    });
  });

  group('PerforatedDivider — hình thức', () {
    testWidgets('mặc định dùng màu đường kẻ của bảng token', (tester) async {
      await tester.pumpWidget(_host(const PerforatedDivider()));

      final painter = tester
          .widget<CustomPaint>(find.byType(CustomPaint).last)
          .painter!;
      expect(painter.toString(), contains('_PerforationPainter'));
    });

    testWidgets('đổi dash/gap thì vẽ lại', (tester) async {
      const a = PerforatedDivider();
      const b = PerforatedDivider(dash: 8, gap: 8);

      await tester.pumpWidget(_host(a));
      final first = tester
          .widget<CustomPaint>(find.byType(CustomPaint).last)
          .painter!;

      await tester.pumpWidget(_host(b));
      final second = tester
          .widget<CustomPaint>(find.byType(CustomPaint).last)
          .painter!;

      expect(second.shouldRepaint(first), isTrue);
    });
  });

  // Không có chữ nên chụp được ngay.
  testWidgets('ảnh vàng — đường xé trong thẻ trắng', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Card(
          child: Padding(
            padding: EdgeInsets.all(AppGap.slip),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppGap.xxl),
                PerforatedDivider(),
                SizedBox(height: AppGap.xxl),
              ],
            ),
          ),
        ),
        width: 260,
      ),
    );

    await expectLater(
      find.byType(Card),
      matchesGoldenFile('goldens/perforated_divider.png'),
    );
  });
}
