import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/notice_card.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';

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

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester.widget<Container>(find.byType(Container).first).decoration!
        as BoxDecoration;

void main() {
  group('NoticeCard — nền theo tone', () {
    testWidgets('tô nền nhạt và viền cùng tone', (tester) async {
      await tester.pumpWidget(
        _host(
          const NoticeCard(
            tone: Tone.money,
            icon: SoloIcons.cash,
            message: 'Minh An chưa thanh toán đợt 2.',
          ),
        ),
      );

      expect(_decorationOf(tester).color, AppColors.momoSoft);
      expect(_decorationOf(tester).border!.top.color, AppColors.momoLine);
    });

    testWidgets('chữ dùng màu đậm để đọc được trên nền nhạt', (tester) async {
      await tester.pumpWidget(
        _host(
          const NoticeCard(
            tone: Tone.warn,
            icon: SoloIcons.clock,
            message: 'Mẫu này thiếu điều khoản bản quyền.',
          ),
        ),
      );

      expect(
        tester
            .widget<Text>(find.text('Mẫu này thiếu điều khoản bản quyền.'))
            .style!
            .color,
        AppColors.amberDeep,
      );
    });

    testWidgets('màu chữ đậm khác hẳn màu tone nguyên bản', (tester) async {
      // Nếu hai màu bằng nhau nghĩa là token onSoft chưa được dùng.
      expect(Tone.warn.onSoft, isNot(Tone.warn.foreground));
      expect(Tone.money.onSoft, isNot(Tone.money.foreground));
    });
  });

  group('NoticeCard — nội dung', () {
    testWidgets('có title thì message xuống dòng dưới', (tester) async {
      await tester.pumpWidget(
        _host(
          const NoticeCard(
            tone: Tone.money,
            icon: SoloIcons.cash,
            title: 'Quá hạn thanh toán',
            message:
                'Minh An chưa thanh toán đợt 2 — 12.500.000 ₫, trễ 6 ngày.',
          ),
        ),
      );

      expect(find.text('Quá hạn thanh toán'), findsOneWidget);
      expect(
        tester.getTopLeft(find.textContaining('Minh An')).dy,
        greaterThan(tester.getTopLeft(find.text('Quá hạn thanh toán')).dy),
      );
    });

    testWidgets('không có title thì chỉ một đoạn nằm cạnh icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const NoticeCard(
            tone: Tone.warn,
            icon: SoloIcons.clock,
            message: 'Còn 2 chỗ trống cần điền trước khi gửi.',
          ),
        ),
      );
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('nhận thêm một chip hành động ở mép phải', (tester) async {
      await tester.pumpWidget(
        _host(
          const NoticeCard(
            tone: Tone.warn,
            icon: SoloIcons.clock,
            message: 'Còn 2 chỗ trống cần điền trước khi gửi.',
            trailing: StatusChip('Điền ngay', tone: Tone.warn),
          ),
        ),
      );
      expect(find.text('Điền ngay'), findsOneWidget);
    });

    testWidgets('icon là trang trí, nội dung đã nói đủ nghĩa', (tester) async {
      await tester.pumpWidget(
        _host(
          const NoticeCard(
            tone: Tone.money,
            icon: SoloIcons.cash,
            message: 'Quá hạn thanh toán.',
          ),
        ),
      );
      expect(tester.widget<SoloIcon>(find.byType(SoloIcon)).label, isNull);
    });
  });

  testWidgets('ảnh vàng — cảnh báo tiền và cảnh báo sắp đến hạn', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(370, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        const Column(
          key: Key('golden-root'),
          mainAxisSize: MainAxisSize.min,
          children: [
            NoticeCard(
              tone: Tone.money,
              icon: SoloIcons.cash,
              title: 'Quá hạn thanh toán',
              message:
                  'Minh An chưa thanh toán đợt 2 — 12.500.000 ₫, trễ 6 ngày.',
            ),
            SizedBox(height: AppGap.betweenCards),
            NoticeCard(
              tone: Tone.warn,
              icon: SoloIcons.clock,
              message: 'Còn 2 chỗ trống cần điền trước khi gửi',
              trailing: StatusChip('Điền ngay', tone: Tone.warn),
            ),
          ],
        ),
      ),
    );

    await expectLater(
      find.byKey(const Key('golden-root')),
      matchesGoldenFile('goldens/notice_card.png'),
    );
  }, skip: !soloFontsLoaded);
}
