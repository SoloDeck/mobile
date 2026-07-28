import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

void main() {
  group('SoloIcons — bộ icon', () {
    test('có đúng 30 icon như khối <defs> của bản phác thảo', () {
      expect(SoloIcons.byName.length, 30);
    });

    test('mọi id khớp với id <symbol> mà nó đại diện', () {
      for (final entry in SoloIcons.byName.entries) {
        expect(entry.value.name, entry.key);
      }
    });

    test('mọi đường vẽ đọc được, không lệnh SVG nào chưa hỗ trợ', () {
      for (final icon in SoloIcons.byName.values) {
        for (final shape in icon.shapes) {
          if (shape is SoloPath) {
            expect(
              () => parseSvgPath(shape.d),
              returnsNormally,
              reason: 'icon ${icon.name} có đường vẽ hỏng: ${shape.d}',
            );
          }
        }
      }
    });

    test('mọi đường vẽ nằm gọn trong khung 24 × 24 và có chiều dài thật', () {
      for (final icon in SoloIcons.byName.values) {
        for (final shape in icon.shapes) {
          if (shape is! SoloPath) continue;
          final bounds = parseSvgPath(shape.d).getBounds();

          // Đoạn thẳng ngang/dọc có một chiều bằng 0 — vẫn hợp lệ, nên chỉ đòi
          // hỏi nó trải dài theo ít nhất một chiều.
          expect(
            bounds.width > 0 || bounds.height > 0,
            isTrue,
            reason: 'icon ${icon.name} có đường vẽ rỗng: ${shape.d}',
          );

          // Vẽ tràn khỏi viewBox là dấu hiệu chép nhầm toạ độ.
          expect(
            bounds.left >= -0.01 &&
                bounds.top >= -0.01 &&
                bounds.right <= 24.01 &&
                bounds.bottom <= 24.01,
            isTrue,
            reason: 'icon ${icon.name} vẽ tràn khung 24×24: $bounds',
          );
        }
      }
    });
  });

  group('parseSvgPath — tập lệnh dùng trong bản phác thảo', () {
    test('toạ độ thừa sau moveto được hiểu là lineto', () {
      // "M0 0 10 0" phải thành một đoạn thẳng, không phải một điểm.
      expect(parseSvgPath('M0 0 10 0').getBounds().width, 10);
    });

    test('dấu trừ tách số mà không cần khoảng trắng', () {
      expect(parseSvgPath('M0 0h10v10h-10z').getBounds().width, 10);
    });

    test('cung tròn dựng đúng bề rộng', () {
      final bounds = parseSvgPath('M0 0a5 5 0 0 1 10 0').getBounds();
      expect(bounds.width, closeTo(10, 0.01));
    });

    test('lệnh chưa hỗ trợ thì ném lỗi thay vì vẽ sai lặng lẽ', () {
      expect(() => parseSvgPath('M0 0Q5 5 10 0'), throwsFormatException);
    });
  });

  group('SoloIcon — ngữ nghĩa', () {
    testWidgets('icon có nhãn thì trình đọc màn hình thấy được', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SoloIcon(SoloIcons.bell, label: 'Thông báo')),
      );
      expect(find.bySemanticsLabel('Thông báo'), findsOneWidget);
    });

    testWidgets('icon trang trí bị loại khỏi cây ngữ nghĩa', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(home: SoloIcon(SoloIcons.bell, label: null)),
      );
      expect(find.bySemanticsLabel('Thông báo'), findsNothing);
      handle.dispose();
    });
  });

  // Ảnh vàng này không có chữ nên chụp được ngay, không phụ thuộc font thật.
  testWidgets('ảnh vàng — cả 30 icon ở ba cỡ', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: AppColors.paper,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final size in [SoloIcon.md, SoloIcon.sm, SoloIcon.xs])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final icon in SoloIcons.byName.values)
                          SoloIcon(icon, label: null, size: size),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/solo_icons.png'),
    );
  });
}
