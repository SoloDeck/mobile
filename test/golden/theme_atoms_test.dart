import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';

import '../flutter_test_config.dart';

/// `Card` và các nút không thành widget riêng — chúng được cấu hình sẵn trong
/// `AppTheme` để màn hình không phải bọc thêm `Container`. File này canh chừng
/// đúng phần cấu hình đó.
Widget _host(Widget child, {double width = 330}) => MaterialApp(
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
  group('AppTheme — Card cấu hình sẵn', () {
    testWidgets('nền trắng, viền 1px, bo 18, không đổ bóng', (tester) async {
      await tester.pumpWidget(_host(const Card(child: SizedBox(height: 40))));

      final card = tester.widget<Card>(find.byType(Card));
      final theme = AppTheme.light().cardTheme;

      expect(card.color ?? theme.color, AppColors.surface);
      expect(theme.elevation, 0);
      expect(theme.margin, EdgeInsets.zero);

      final shape = theme.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, AppRadius.cardAll);
      expect(shape.side.color, AppColors.line);
    });

    testWidgets('không cần bọc Container để đổi nền hay viền', (tester) async {
      await tester.pumpWidget(_host(const Card(child: SizedBox(height: 40))));

      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Container),
        ),
        findsNothing,
      );
    });
  });

  group('AppTheme — nút', () {
    testWidgets('nút đặc cao 46 và bo 14', (tester) async {
      final style = AppTheme.filled();
      expect(style.minimumSize!.resolve({})!.height, 46);
      final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppRadius.button));
    });

    testWidgets('biến thể nhỏ cao 38 và bo 11', (tester) async {
      final style = AppTheme.filled(small: true);
      expect(style.minimumSize!.resolve({})!.height, 38);
      final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppRadius.buttonSm));
    });

    testWidgets('tone đổi màu nền nút theo ngữ nghĩa', (tester) async {
      expect(AppTheme.filled().backgroundColor!.resolve({}), AppColors.ink);
      expect(
        AppTheme.filled(tone: Tone.money).backgroundColor!.resolve({}),
        AppColors.momo,
      );
      expect(
        AppTheme.filled(tone: Tone.ai).backgroundColor!.resolve({}),
        AppColors.ai,
      );
    });

    testWidgets('nút viền trong suốt, viền mực dày 1.5', (tester) async {
      final style = AppTheme.outlined();
      expect(style.backgroundColor!.resolve({}), Colors.transparent);
      expect(style.side!.resolve({})!.color, AppColors.ink);
      expect(style.side!.resolve({})!.width, 1.5);
    });
  });

  testWidgets('ảnh vàng — thẻ và năm biến thể nút', (tester) async {
    await tester.binding.setSurfaceSize(const Size(370, 340));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppGap.card),
                child: Text('Thẻ thường — dùng cho nội dung không phải tiền'),
              ),
            ),
            const SizedBox(height: AppGap.betweenCards),
            FilledButton(
              onPressed: () {},
              style: AppTheme.filled(),
              child: const Text('Tiếp tục với Google'),
            ),
            const SizedBox(height: AppGap.betweenButtons),
            FilledButton(
              onPressed: () {},
              style: AppTheme.filled(tone: Tone.money),
              child: const Text('Gửi ngay'),
            ),
            const SizedBox(height: AppGap.betweenButtons),
            FilledButton(
              onPressed: () {},
              style: AppTheme.filled(tone: Tone.ai),
              child: const Text('Xem và duyệt'),
            ),
            const SizedBox(height: AppGap.betweenButtons),
            OutlinedButton(
              onPressed: () {},
              style: AppTheme.outlined(),
              child: const Text('Đăng nhập bằng email'),
            ),
            const SizedBox(height: AppGap.betweenButtons),
            FilledButton(
              onPressed: () {},
              style: AppTheme.filled(tone: Tone.money, small: true),
              child: const Text('Gửi nhắc qua Zalo'),
            ),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/theme_atoms.png'),
    );
  }, skip: !soloFontsLoaded);
}
