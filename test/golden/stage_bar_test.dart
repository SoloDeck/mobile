import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/stage_bar.dart';

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
  group('StageBar — dạng tỉ lệ (MÀN 04)', () {
    testWidgets('sáu đoạn, mỗi đoạn một màu giai đoạn', (tester) async {
      await tester.pumpWidget(
        _host(const StageBar.proportional(weights: [4, 2, 3, 1, 3, 2])),
      );

      final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      expect(boxes.length, StageBar.stageCount);

      final colors = boxes
          .map((b) => (b.decoration as BoxDecoration).color)
          .toList();
      expect(colors, StageBar.stageColors);
    });

    testWidgets('đoạn rộng theo số deal đang đứng ở giai đoạn đó', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StageBar.proportional(weights: [4, 2, 3, 1, 3, 2])),
      );

      final flexes = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .map((e) => e.flex)
          .toList();
      expect(flexes, [4, 2, 3, 1, 3, 2]);
    });

    testWidgets('giai đoạn rỗng vẫn chiếm chỗ, không biến mất', (tester) async {
      await tester.pumpWidget(
        _host(const StageBar.proportional(weights: [4, 0, 3, 0, 3, 2])),
      );

      final flexes = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .map((e) => e.flex)
          .toList();
      expect(flexes, [4, 1, 3, 1, 3, 2]);
      expect(flexes.every((f) => f > 0), isTrue);
    });

    testWidgets('cao 3 và có khe hở giữa các đoạn', (tester) async {
      await tester.pumpWidget(
        _host(const StageBar.proportional(weights: [1, 1, 1, 1, 1, 1])),
      );
      expect(tester.getSize(find.byType(StageBar)).height, 3);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('từng đoạn vẽ ra có chiều cao thật, không co về 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StageBar.proportional(weights: [4, 2, 3, 1, 3, 2])),
      );

      for (var i = 0; i < StageBar.stageCount; i++) {
        expect(
          tester.getSize(find.byType(DecoratedBox).at(i)).height,
          3,
          reason: 'đoạn $i',
        );
      }
    });
  });

  group('StageBar — dạng bước (MÀN 05)', () {
    testWidgets('tô đầy tới bước hiện tại, phần còn lại là màu đường kẻ', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const StageBar.steps(filledSteps: 5)));

      final colors = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => (b.decoration as BoxDecoration).color)
          .toList();

      expect(colors.take(5).every((c) => c == AppColors.stage5), isTrue);
      expect(colors.last, AppColors.line);
    });

    testWidgets('sáu đoạn đều nhau', (tester) async {
      await tester.pumpWidget(_host(const StageBar.steps(filledSteps: 3)));

      final flexes = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .map((e) => e.flex)
          .toList();
      expect(flexes, List.filled(StageBar.stageCount, 1));
    });

    testWidgets('cao 5 và không có khe hở', (tester) async {
      await tester.pumpWidget(_host(const StageBar.steps(filledSteps: 5)));
      expect(tester.getSize(find.byType(StageBar)).height, 5);
    });

    testWidgets('chỉ bo hai đầu ngoài cùng của cả dải', (tester) async {
      await tester.pumpWidget(_host(const StageBar.steps(filledSteps: 5)));

      final radii = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => (b.decoration as BoxDecoration).borderRadius)
          .toList();

      expect(radii.first, isNot(BorderRadius.zero));
      expect(radii.last, isNot(BorderRadius.zero));
      expect(radii[2], BorderRadius.zero);
    });

    testWidgets('chưa đi bước nào thì cả dải là màu đường kẻ', (tester) async {
      await tester.pumpWidget(_host(const StageBar.steps(filledSteps: 0)));

      final colors = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => (b.decoration as BoxDecoration).color)
          .toList();
      expect(colors.every((c) => c == AppColors.line), isTrue);
    });
  });

  group('StageBar — quy tắc 4', () {
    testWidgets('dải chỉ để đọc, không nhận kéo thả', (tester) async {
      await tester.pumpWidget(
        _host(const StageBar.proportional(weights: [4, 2, 3, 1, 3, 2])),
      );

      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });
  });

  // Không có chữ nên chụp được ngay.
  testWidgets('ảnh vàng — hai dạng dải giai đoạn', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 90));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StageBar.proportional(weights: [4, 2, 3, 1, 3, 2]),
            SizedBox(height: AppGap.xxl),
            StageBar.steps(filledSteps: 5),
          ],
        ),
        width: 240,
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/stage_bar.png'),
    );
  });
}
