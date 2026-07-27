import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: ColoredBox(
    color: AppColors.paper,
    child: Padding(
      padding: const EdgeInsets.all(AppGap.xl),
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  ),
);

void main() {
  group('IconButtonBox — vùng chạm', () {
    testWidgets('hộp bố cục đủ 44 dù hình vẽ chỉ 38', (tester) async {
      await tester.pumpWidget(
        _host(const IconButtonBox(SoloIcons.bell, label: 'Thông báo')),
      );

      final size = tester.getSize(find.byType(IconButtonBox));
      expect(size.width, IconButtonBox.tapTarget);
      expect(size.height, IconButtonBox.tapTarget);
    });

    testWidgets('phần vẽ ra vẫn đúng 38 của bản phác thảo', (tester) async {
      await tester.pumpWidget(
        _host(const IconButtonBox(SoloIcons.bell, label: 'Thông báo')),
      );

      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(IconButtonBox),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(box.constraints?.maxWidth, IconButtonBox.defaultVisualSize);
    });

    testWidgets('overhang khớp chênh lệch giữa hai kích thước', (tester) async {
      expect(IconButtonBox.overhang, 3);
      expect(
        IconButtonBox.defaultVisualSize + IconButtonBox.overhang * 2,
        IconButtonBox.tapTarget,
      );
    });

    testWidgets('bấm được trên phần thò ra ngoài hình vẽ', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          IconButtonBox(
            SoloIcons.bell,
            label: 'Thông báo',
            onTap: () => taps++,
          ),
        ),
      );

      // Góc trên trái của hộp 44 nằm ngoài ô vẽ 38 nhưng vẫn phải nhận chạm.
      final topLeft = tester.getTopLeft(find.byType(IconButtonBox));
      await tester.tapAt(topLeft + const Offset(1.5, 1.5));
      expect(taps, 1);
    });
  });

  group('IconButtonBox — hình thức', () {
    testWidgets('mặc định là nền trắng viền xám', (tester) async {
      await tester.pumpWidget(
        _host(const IconButtonBox(SoloIcons.search, label: 'Tìm kiếm')),
      );

      final decoration =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(IconButtonBox),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;

      expect(decoration.color, AppColors.surface);
      expect(decoration.border!.top.color, AppColors.line);
    });

    testWidgets('ghost thì trong suốt cả nền lẫn viền', (tester) async {
      await tester.pumpWidget(
        _host(
          const IconButtonBox(SoloIcons.back, label: 'Quay lại', ghost: true),
        ),
      );

      final decoration =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(IconButtonBox),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;

      expect(decoration.color, Colors.transparent);
      expect(decoration.border!.top.color, Colors.transparent);
    });

    testWidgets('tone tô nền và đổi màu icon theo ngữ nghĩa', (tester) async {
      await tester.pumpWidget(
        _host(
          const IconButtonBox(
            SoloIcons.send,
            label: 'Nhắn Zalo',
            tone: Tone.ok,
            visualSize: 34,
          ),
        ),
      );

      final decoration =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(IconButtonBox),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;

      expect(decoration.color, AppColors.jadeSoft);
      expect(decoration.border!.top.color, AppColors.jadeLine);
      expect(
        tester.widget<SoloIcon>(find.byType(SoloIcon)).color,
        AppColors.jade,
      );
    });

    testWidgets('chấm báo chỉ hiện khi được bật', (tester) async {
      await tester.pumpWidget(
        _host(const IconButtonBox(SoloIcons.bell, label: 'Thông báo')),
      );
      expect(find.byType(Stack), findsNothing);

      await tester.pumpWidget(
        _host(
          const IconButtonBox(
            SoloIcons.bell,
            label: 'Thông báo',
            showDot: true,
          ),
        ),
      );
      expect(find.byType(Stack), findsOneWidget);
    });
  });

  group('IconButtonBox — ngữ nghĩa', () {
    testWidgets('là nút và có nhãn tiếng Việt', (tester) async {
      await tester.pumpWidget(
        _host(const IconButtonBox(SoloIcons.dots, label: 'Thêm lựa chọn')),
      );

      final node = tester.getSemantics(find.byType(IconButtonBox).first);
      expect(node.label, 'Thêm lựa chọn');
    });

    testWidgets('icon bên trong không tự thêm nhãn thứ hai', (tester) async {
      await tester.pumpWidget(
        _host(const IconButtonBox(SoloIcons.dots, label: 'Thêm lựa chọn')),
      );
      expect(tester.widget<SoloIcon>(find.byType(SoloIcon)).label, isNull);
    });
  });

  // Không có chữ nên chụp được ngay, không chờ font.
  testWidgets('ảnh vàng — mặc định, ghost, tone ngọc, có chấm báo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(260, 90));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButtonBox(SoloIcons.search, label: 'Tìm kiếm'),
            IconButtonBox(SoloIcons.back, label: 'Quay lại', ghost: true),
            IconButtonBox(SoloIcons.send, label: 'Nhắn Zalo', tone: Tone.ok),
            IconButtonBox(SoloIcons.bell, label: 'Thông báo', showDot: true),
          ],
        ),
      ),
    );

    await expectLater(
      find.byType(Row),
      matchesGoldenFile('goldens/icon_button_box.png'),
    );
  });
}
