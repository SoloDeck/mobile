import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';

const _stages = [
  'Lead mới · 4',
  'Đủ điều kiện · 2',
  'Đã gửi BG · 3',
  'Đàm phán',
  'Đã chốt · 1',
  'Thất bại',
];

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Align(alignment: Alignment.topCenter, child: child),
  ),
);

void main() {
  group('FilterChipBar — chọn nhóm', () {
    testWidgets('chip đang chọn dùng nền mực đặc, các chip khác trung tính', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const FilterChipBar(labels: _stages, selectedIndex: 0)),
      );

      final chips = tester.widgetList<StatusChip>(find.byType(StatusChip));
      expect(chips.first.tone, Tone.solid);
      expect(chips.skip(1).every((c) => c.tone == Tone.neutral), isTrue);
    });

    testWidgets('bấm chip báo về đúng vị trí', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        _host(
          FilterChipBar(
            labels: _stages,
            selectedIndex: 0,
            onSelected: tapped.add,
          ),
        ),
      );

      await tester.tap(find.text('Đủ điều kiện · 2'));
      expect(tapped, [1]);
    });

    testWidgets('không có onSelected thì chip trơ, không nổ', (tester) async {
      await tester.pumpWidget(
        _host(const FilterChipBar(labels: _stages, selectedIndex: 2)),
      );

      await tester.tap(find.text('Lead mới · 4'));
      expect(tester.takeException(), isNull);
    });
  });

  group('FilterChipBar — vùng chạm và cuộn', () {
    testWidgets('cả dải cao đúng 44 để mỗi chip đủ vùng chạm', (tester) async {
      await tester.pumpWidget(
        _host(const FilterChipBar(labels: _stages, selectedIndex: 0)),
      );

      expect(
        tester.getSize(find.byType(FilterChipBar)).height,
        FilterChipBar.tapTarget,
      );
    });

    testWidgets('cuộn ngang được khi sáu giai đoạn không vừa màn hình', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(const FilterChipBar(labels: _stages, selectedIndex: 0)),
      );

      final before = tester.getTopLeft(find.text('Lead mới · 4')).dx;
      await tester.drag(find.byType(FilterChipBar), const Offset(-120, 0));
      await tester.pump();
      final after = tester.getTopLeft(find.text('Lead mới · 4')).dx;

      expect(after, lessThan(before));
    });
  });

  group('FilterChipBar — quy tắc 4', () {
    testWidgets('không dựng bất kỳ thành phần kéo thả nào', (tester) async {
      await tester.pumpWidget(
        _host(const FilterChipBar(labels: _stages, selectedIndex: 0)),
      );

      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
      expect(find.byType(LongPressDraggable<Object>), findsNothing);
    });
  });

  group('FilterChipBar — ngữ nghĩa', () {
    testWidgets('trình đọc màn hình biết chip nào đang được chọn', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const FilterChipBar(labels: _stages, selectedIndex: 1)),
      );

      expect(
        find.bySemanticsLabel('Đủ điều kiện · 2'),
        findsOneWidget,
        reason: 'chip đang chọn phải đọc được',
      );
      handle.dispose();
    });
  });

  testWidgets('ảnh vàng — dải giai đoạn pipeline của MÀN 04', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 70));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(const FilterChipBar(labels: _stages, selectedIndex: 0)),
    );

    await expectLater(
      find.byType(FilterChipBar),
      matchesGoldenFile('goldens/filter_chip_bar.png'),
    );
  }, skip: !soloFontsLoaded);
}
