import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Center(
      child: Padding(padding: const EdgeInsets.all(AppGap.xl), child: child),
    ),
  ),
);

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(Avatar),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  group('Avatar — màu theo tone', () {
    testWidgets('bốn tone có nghĩa dùng nền chuyển sắc', (tester) async {
      const pairs = {
        Tone.money: [AppColors.momo, AppColors.avP2],
        Tone.ai: [AppColors.ai, AppColors.avV2],
        Tone.ok: [AppColors.jade, AppColors.avJ2],
        Tone.warn: [AppColors.amber, AppColors.avA2],
      };

      for (final entry in pairs.entries) {
        await tester.pumpWidget(_host(Avatar.initials('MA', tone: entry.key)));
        final gradient = _decorationOf(tester).gradient! as LinearGradient;
        expect(
          gradient.colors,
          entry.value,
          reason: 'gradient của ${entry.key}',
        );
      }
    });

    testWidgets('solid là mực đặc, neutral là xám của deal nguội', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const Avatar.initials('HL')));
      expect(_decorationOf(tester).color, AppColors.ink);
      expect(_decorationOf(tester).gradient, isNull);

      await tester.pumpWidget(
        _host(const Avatar.initials('NL', tone: Tone.neutral)),
      );
      expect(_decorationOf(tester).color, AppColors.ink3);
    });
  });

  group('Avatar — ba cỡ của bản phác thảo', () {
    testWidgets('mỗi cỡ có bo góc riêng', (tester) async {
      // Danh sách bản ghi thay vì Map: khoá double không dùng được cho const Map.
      const expected = <(double, double)>[
        (Avatar.sm, AppRadius.avatar),
        (Avatar.md, 14),
        (Avatar.lg, 18),
      ];

      for (final (size, radius) in expected) {
        await tester.pumpWidget(_host(Avatar.initials('MA', size: size)));

        expect(tester.getSize(find.byType(Avatar)).width, size);
        expect(
          _decorationOf(tester).borderRadius,
          BorderRadius.circular(radius),
          reason: 'bo góc ở cỡ $size',
        );
      }
    });

    testWidgets('cỡ lớn nhất đổi sang chữ tiêu đề', (tester) async {
      await tester.pumpWidget(
        _host(const Avatar.initials('S', size: Avatar.lg)),
      );
      final style = tester.widget<Text>(find.text('S')).style!;

      expect(style.fontFamily, AppFontFamily.display);
      expect(style.fontSize, 22);
    });

    testWidgets('bo góc ép tay thì thắng giá trị suy ra từ cỡ', (tester) async {
      await tester.pumpWidget(
        _host(const Avatar.initials('MA', size: Avatar.sm, radius: 4)),
      );
      expect(_decorationOf(tester).borderRadius, BorderRadius.circular(4));
    });
  });

  group('Avatar — nội dung', () {
    testWidgets('chữ cái viết tắt hiện đúng, màu trắng', (tester) async {
      await tester.pumpWidget(
        _host(const Avatar.initials('TN', tone: Tone.ok)),
      );
      expect(find.text('TN'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('TN')).style!.color,
        AppColors.surface,
      );
    });

    testWidgets('biến thể icon vẽ icon trắng thay cho chữ', (tester) async {
      await tester.pumpWidget(
        _host(const Avatar.icon(SoloIcons.ai, tone: Tone.ai)),
      );

      final icon = tester.widget<SoloIcon>(find.byType(SoloIcon));
      expect(icon.color, AppColors.surface);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('icon trong avatar là trang trí, tên đã nằm ở dòng bên cạnh', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const Avatar.icon(SoloIcons.file)));
      expect(tester.widget<SoloIcon>(find.byType(SoloIcon)).label, isNull);
    });
  });

  testWidgets('ảnh vàng — sáu tone, ba cỡ, và biến thể icon', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Avatar.initials('MA', tone: Tone.money),
                SizedBox(width: AppGap.md),
                Avatar.initials('VP', tone: Tone.ai),
                SizedBox(width: AppGap.md),
                Avatar.initials('TN', tone: Tone.ok),
                SizedBox(width: AppGap.md),
                Avatar.initials('HP', tone: Tone.warn),
                SizedBox(width: AppGap.md),
                Avatar.initials('HL'),
                SizedBox(width: AppGap.md),
                Avatar.initials('NL', tone: Tone.neutral),
              ],
            ),
            SizedBox(height: AppGap.xl),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Avatar.initials('MA', tone: Tone.money, size: Avatar.md),
                SizedBox(width: AppGap.md),
                Avatar.initials('S', tone: Tone.ai, size: Avatar.lg),
                SizedBox(width: AppGap.md),
                Avatar.icon(SoloIcons.ai, tone: Tone.ai),
                SizedBox(width: AppGap.md),
                Avatar.icon(SoloIcons.file, tone: Tone.neutral),
              ],
            ),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/avatar.png'),
    );
  }, skip: !soloFontsLoaded);
}
