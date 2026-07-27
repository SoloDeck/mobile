import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    // Dải nổi phải chiếm hết bề ngang như khi đặt ở đáy màn thật; `Align` sẽ co
    // nó lại bằng bề rộng cái nút.
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [const Spacer(), child],
    ),
  ),
);

void main() {
  group('BottomActionBar — dải nổi', () {
    testWidgets('gradient chạy từ trong suốt sang màu giấy', (tester) async {
      await tester.pumpWidget(
        _host(
          BottomActionBar(
            child: FilledButton(
              onPressed: () {},
              child: const Text('Gửi ngay'),
            ),
          ),
        ),
      );

      final gradient =
          (tester
                          .widget<DecoratedBox>(
                            find
                                .descendant(
                                  of: find.byType(BottomActionBar),
                                  matching: find.byType(DecoratedBox),
                                )
                                .first,
                          )
                          .decoration
                      as BoxDecoration)
                  .gradient!
              as LinearGradient;

      expect(gradient.colors.first.a, 0);
      expect(gradient.colors.last, AppColors.paper);
      expect(gradient.stops, [0, 0.26]);
    });

    testWidgets('cùng một màu giấy, chỉ khác độ trong', (tester) async {
      await tester.pumpWidget(
        _host(
          BottomActionBar(
            child: FilledButton(
              onPressed: () {},
              child: const Text('Gửi ngay'),
            ),
          ),
        ),
      );

      final gradient =
          (tester
                          .widget<DecoratedBox>(
                            find
                                .descendant(
                                  of: find.byType(BottomActionBar),
                                  matching: find.byType(DecoratedBox),
                                )
                                .first,
                          )
                          .decoration
                      as BoxDecoration)
                  .gradient!
              as LinearGradient;

      expect(gradient.colors.first.r, AppColors.paper.r);
      expect(gradient.colors.first.g, AppColors.paper.g);
      expect(gradient.colors.first.b, AppColors.paper.b);
    });

    testWidgets('lề trái phải đúng lề màn hình', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          BottomActionBar(
            child: FilledButton(
              onPressed: () {},
              child: const Text('Gửi ngay'),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.byType(FilledButton)).dx, AppGap.screen);
    });
  });

  group('BottomActionBar — chú thích', () {
    testWidgets('không có caption thì chỉ có nút', (tester) async {
      await tester.pumpWidget(
        _host(
          BottomActionBar(
            child: FilledButton(
              onPressed: () {},
              child: const Text('Gửi ngay'),
            ),
          ),
        ),
      );
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('caption nằm dưới nút và căn giữa', (tester) async {
      await tester.pumpWidget(
        _host(
          BottomActionBar(
            caption: 'Huỷ tự động gia hạn bất cứ lúc nào',
            child: FilledButton(
              onPressed: () {},
              child: const Text('Gửi ngay'),
            ),
          ),
        ),
      );

      final caption = find.text('Huỷ tự động gia hạn bất cứ lúc nào');
      expect(
        tester.getTopLeft(caption).dy,
        greaterThan(tester.getTopLeft(find.byType(FilledButton)).dy),
      );
      expect(tester.widget<Text>(caption).textAlign, TextAlign.center);
    });
  });

  testWidgets('ảnh vàng — dải hành động của MÀN 08', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 130));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        BottomActionBar(
          caption: 'Gửi qua Zalo OA · kèm link xem bản PDF',
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: AppTheme.outlined(),
                child: const Text('Sửa'),
              ),
              const SizedBox(width: AppGap.betweenButtons),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: AppTheme.filled(),
                  icon: const SoloIcon(
                    SoloIcons.send,
                    label: null,
                    size: SoloIcon.sm,
                    color: AppColors.surface,
                  ),
                  label: const Text('Duyệt và gửi khách'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(BottomActionBar),
      matchesGoldenFile('goldens/bottom_action_bar.png'),
    );
  }, skip: !soloFontsLoaded);
}
