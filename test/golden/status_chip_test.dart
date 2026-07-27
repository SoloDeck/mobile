import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

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
  group('StatusChip — ngữ nghĩa màu', () {
    testWidgets('mỗi tone lấy đúng bộ nền / chữ / viền của nó', (tester) async {
      for (final tone in Tone.values) {
        await tester.pumpWidget(_host(StatusChip('Thử', tone: tone)));

        final container = tester.widget<Container>(
          find
              .ancestor(of: find.text('Thử'), matching: find.byType(Container))
              .first,
        );
        final decoration = container.decoration! as BoxDecoration;

        expect(decoration.color, tone.background, reason: 'nền của $tone');
        expect(
          decoration.border!.top.color,
          tone.border,
          reason: 'viền của $tone',
        );
        expect(
          tester.widget<Text>(find.text('Thử')).style!.color,
          tone.foreground,
          reason: 'chữ của $tone',
        );
      }
    });

    testWidgets('tiền là hồng, AI là tím — quy ước cứng', (tester) async {
      await tester.pumpWidget(
        _host(const StatusChip('2 quá hạn', tone: Tone.money)),
      );
      expect(
        tester.widget<Text>(find.text('2 quá hạn')).style!.color,
        AppColors.momo,
      );

      await tester.pumpWidget(_host(const StatusChip('Chờ AI', tone: Tone.ai)));
      expect(
        tester.widget<Text>(find.text('Chờ AI')).style!.color,
        AppColors.ai,
      );
    });
  });

  group('StatusChip — nội dung', () {
    testWidgets('chữ không xuống dòng', (tester) async {
      await tester.pumpWidget(_host(const StatusChip('Quá hạn 6 ngày')));
      expect(
        tester.widget<Text>(find.text('Quá hạn 6 ngày')).softWrap,
        isFalse,
      );
    });

    testWidgets('icon trước và sau chữ đều dựng được', (tester) async {
      await tester.pumpWidget(
        _host(
          const StatusChip(
            'AI soạn',
            tone: Tone.ai,
            icon: SoloIcons.ai,
            trailingIcon: SoloIcons.chevron,
          ),
        ),
      );
      expect(find.byType(SoloIcon), findsNWidgets(2));
    });

    testWidgets('icon trong chip là trang trí, không lọt vào cây ngữ nghĩa', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StatusChip('AI soạn', tone: Tone.ai, icon: SoloIcons.ai)),
      );
      for (final icon in tester.widgetList<SoloIcon>(find.byType(SoloIcon))) {
        expect(icon.label, isNull);
      }
    });

    testWidgets('biến thể mono dùng chữ mono, không phải chữ thân bài', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StatusChip('{{price}}', mono: true)));
      expect(
        tester.widget<Text>(find.text('{{price}}')).style!.fontFamily,
        'IBM Plex Mono',
      );
    });
  });

  testWidgets('ảnh vàng — sáu tone, có icon, và biến thể mono', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Wrap(
          spacing: AppGap.betweenChips,
          runSpacing: AppGap.betweenChips,
          children: [
            StatusChip('Tất cả'),
            StatusChip('2 quá hạn', tone: Tone.money),
            StatusChip('Chờ AI', tone: Tone.ai),
            StatusChip('Đã thu', tone: Tone.ok),
            StatusChip('1 sắp đến hạn', tone: Tone.warn),
            StatusChip('Lead mới · 4', tone: Tone.solid),
            StatusChip('AI soạn', tone: Tone.ai, icon: SoloIcons.ai),
            StatusChip('2026', trailingIcon: SoloIcons.chevron),
            StatusChip('{{client_name}}', tone: Tone.ai, mono: true),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Wrap),
      matchesGoldenFile('goldens/status_chip.png'),
    );
  }, skip: !soloFontsLoaded);
}
