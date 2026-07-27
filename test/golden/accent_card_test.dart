import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';

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

/// Vạch màu bên trong thẻ. Phải lọc theo cây con của `AccentCard`, vì khung chứa
/// của test cũng là một `ColoredBox`.
final _stripOf = find.descendant(
  of: find.byType(AccentCard),
  matching: find.byType(ColoredBox),
);

void main() {
  group('AccentCard — vạch màu', () {
    testWidgets('vạch dày đúng 3 và chạy hết chiều cao thẻ', (tester) async {
      await tester.pumpWidget(
        _host(
          const AccentCard(
            child: SizedBox(height: 60, child: Text('Nhắc thanh toán')),
          ),
        ),
      );

      final strip = tester.getSize(_stripOf);
      expect(strip.width, AccentCard.accentWidth);
      expect(strip.height, greaterThan(60));
    });

    testWidgets('mỗi tone cho một màu vạch khác nhau', (tester) async {
      const expected = {
        Tone.money: AppColors.momo,
        Tone.ai: AppColors.ai,
        Tone.warn: AppColors.amber,
        Tone.ok: AppColors.jade,
      };

      for (final entry in expected.entries) {
        await tester.pumpWidget(
          _host(
            AccentCard(
              tone: entry.key,
              child: const SizedBox(height: 40, child: Text('Việc')),
            ),
          ),
        );

        expect(
          tester.widget<ColoredBox>(_stripOf).color,
          entry.value,
          reason: 'vạch của ${entry.key}',
        );
      }
    });

    testWidgets('thân thẻ vẫn nền trắng viền xám như Card thường', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const AccentCard(child: SizedBox(height: 40))),
      );

      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(AccentCard),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;

      expect(decoration.color, AppColors.surface);
      expect(decoration.border!.top.color, AppColors.line);
    });
  });

  testWidgets(
    'ảnh vàng — ba việc của MÀN 02, phân biệt bằng vạch màu',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 260));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccentCard(
                child: Text(
                  'Nhắc thanh toán · Minh An',
                  style: AppText.bodyStrong,
                ),
              ),
              SizedBox(height: AppGap.betweenCards),
              AccentCard(
                tone: Tone.ai,
                child: Text('Báo giá đã soạn xong', style: AppText.bodyStrong),
              ),
              SizedBox(height: AppGap.betweenCards),
              AccentCard(
                tone: Tone.warn,
                child: Text('2 task trễ hạn', style: AppText.bodyStrong),
              ),
            ],
          ),
        ),
      );

      await expectLater(
        find.byType(Column),
        matchesGoldenFile('goldens/accent_card.png'),
      );
    },
    skip: !soloFontsLoaded,
  );
}
