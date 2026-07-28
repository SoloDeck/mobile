import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Align(alignment: Alignment.bottomCenter, child: child),
  ),
);

Container _fabOf(WidgetTester tester) => tester.widget<Container>(
  find
      .descendant(of: find.byType(SoloNavBar), matching: find.byType(Container))
      .last,
);

void main() {
  group('SoloNavBar — bốn mục gốc', () {
    testWidgets('đúng bốn mục, đúng chữ của bản phác thảo', (tester) async {
      await tester.pumpWidget(_host(const SoloNavBar(index: 0)));

      expect(SoloNavBar.destinations.length, 4);
      expect(find.text('Hôm nay'), findsOneWidget);
      expect(find.text('Pipeline'), findsOneWidget);
      expect(find.text('Dự án'), findsOneWidget);
      expect(find.text('Tôi'), findsOneWidget);
    });

    testWidgets('mục đang mở dùng màu mực, các mục khác màu mờ', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const SoloNavBar(index: 1)));

      expect(
        tester.widget<Text>(find.text('Pipeline')).style!.color,
        AppColors.ink,
      );
      expect(
        tester.widget<Text>(find.text('Hôm nay')).style!.color,
        AppColors.ink3,
      );
    });

    testWidgets('bấm mục báo về đúng vị trí', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        _host(SoloNavBar(index: 0, onSelect: tapped.add)),
      );

      await tester.tap(find.text('Dự án'));
      expect(tapped, [2]);
    });

    testWidgets('cả thanh cao đúng 84', (tester) async {
      await tester.pumpWidget(_host(const SoloNavBar(index: 0)));
      expect(tester.getSize(find.byType(SoloNavBar)).height, SoloNavBar.height);
    });
  });

  group('SoloNavBar — nút ghi nhanh', () {
    testWidgets('bấm ＋ mở ghi nhanh, không phải một tab', (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        _host(SoloNavBar(index: 0, onQuickCapture: () => opened++)),
      );

      await tester.tap(find.bySemanticsLabel('Ghi nhanh bằng giọng nói'));
      expect(opened, 1);
    });

    testWidgets('nút ＋ nhô lên khỏi thanh', (tester) async {
      await tester.pumpWidget(_host(const SoloNavBar(index: 0)));

      final navTop = tester.getTopLeft(find.byType(SoloNavBar)).dy;
      final fabTop = tester.getTopLeft(find.byType(SoloIcon).at(2)).dy;
      expect(fabTop, lessThan(navTop + 20));
    });

    testWidgets('ngoại tuyến thì nút ＋ chuyển xám', (tester) async {
      await tester.pumpWidget(_host(const SoloNavBar(index: 0)));
      expect(
        (_fabOf(tester).decoration! as BoxDecoration).color,
        AppColors.ink,
      );

      await tester.pumpWidget(_host(const SoloNavBar(index: 0, offline: true)));
      expect(
        (_fabOf(tester).decoration! as BoxDecoration).color,
        AppColors.ink3,
      );
    });

    testWidgets('ngoại tuyến vẫn bấm được các tab — không chặn thao tác', (
      tester,
    ) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        _host(SoloNavBar(index: 0, offline: true, onSelect: tapped.add)),
      );

      await tester.tap(find.text('Tôi'));
      expect(tapped, [3]);
    });
  });

  group('SoloNavBar — ngữ nghĩa', () {
    testWidgets('trình đọc màn hình biết mục nào đang mở', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const SoloNavBar(index: 2)));

      expect(find.bySemanticsLabel('Dự án'), findsWidgets);
      handle.dispose();
    });
  });

  testWidgets('ảnh vàng — thanh tab thường và khi ngoại tuyến', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 190));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          key: Key('golden-root'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SoloNavBar(index: 0),
            SizedBox(height: 20),
            SoloNavBar(index: 3, offline: true),
          ],
        ),
      ),
    );

    await expectLater(
      find.byKey(const Key('golden-root')),
      matchesGoldenFile('goldens/solo_nav_bar.png'),
    );
  }, skip: !soloFontsLoaded);
}
