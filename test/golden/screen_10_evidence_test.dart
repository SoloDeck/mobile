import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/evidence_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';

import '../flutter_test_config.dart';
import '../support/fake_settings_repository.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const EvidencePage(projectId: 'p1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 10 — cấu trúc theo figcaption', () {
    testWidgets('file nhóm theo mốc bàn giao, không theo thư mục', (
      tester,
    ) async {
      await _pump(tester);

      final labels = tester
          .widgetList<SectionLabel>(find.byType(SectionLabel))
          .map((w) => w.text)
          .toList();
      // Ba nhãn: hai mốc thời gian bàn giao (không phải tên thư mục) và nhãn
      // "File đang chọn" của thẻ bên dưới.
      expect(labels, [
        'Hôm nay · 25/07',
        '21/07 · Đợt nháp 1',
        'File đang chọn',
      ]);

      // SectionLabel tự in hoa khi vẽ ra, nên tìm đúng chuỗi đã hiển thị.
      final firstLabelTop = tester.getTopLeft(find.text('HÔM NAY · 25/07')).dy;
      final secondLabelTop = tester
          .getTopLeft(find.text('21/07 · ĐỢT NHÁP 1'))
          .dy;
      expect(firstLabelTop, lessThan(secondLabelTop));
    });

    testWidgets('ảnh Zalo nằm cùng hàng với file gốc, không tách riêng', (
      tester,
    ) async {
      await _pump(tester);

      // So đỉnh của ô vuông chứa từng file (không phải chữ bên trong, vì
      // caption ảnh nằm sát đáy ô còn tên file PDF nằm giữa ô) — cả ba ô
      // vuông phải thẳng hàng nhau vì cùng một `_TileRow`.
      double tileTopY(Finder textFinder) {
        final tile = find.ancestor(
          of: textFinder,
          matching: find.byType(AspectRatio),
        );
        return tester.getTopLeft(tile.first).dy;
      }

      final logoTop = tileTopY(find.text('logo_v2.png').first);
      final zaloTop = tileTopY(find.text('zalo_gui.jpg'));
      final guidelineTop = tileTopY(find.text('guideline.pdf'));
      expect(zaloTop, logoTop);
      expect(guidelineTop, logoTop);
    });

    testWidgets('nút tạo link luôn hiện rõ thời hạn 7 ngày ngay trên nút', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('Tạo link 7 ngày'), findsOneWidget);
      // Không rút gọn thành "Tạo link".
      expect(find.text('Tạo link'), findsNothing);
    });

    testWidgets('thanh dung lượng gói nằm ở đáy thân màn, trên dải hành động', (
      tester,
    ) async {
      await _pump(tester);

      final progressTop = tester.getTopLeft(find.byType(ProgressBar)).dy;
      final firstLabelTop = tester
          .getTopLeft(find.byType(SectionLabel).first)
          .dy;
      final actionBarTop = tester.getTopLeft(find.byType(BottomActionBar)).dy;

      // Thấp hơn (dy lớn hơn) mọi lưới file phía trên, nhưng nội dung cuộn
      // được nên vẫn nằm phía trên dải hành động nổi cố định ở đáy khung nhìn.
      expect(progressTop, greaterThan(firstLabelTop));
      expect(actionBarTop, lessThanOrEqualTo(844));
    });

    testWidgets('màn không có SoloNavBar, hành động chính nổi riêng ở đáy', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SoloNavBar), findsNothing);
      expect(find.byType(BottomActionBar), findsOneWidget);
      expect(find.text('Chụp hoặc chọn file'), findsOneWidget);
    });

    testWidgets('nút quay lại là ghost, nút tìm kiếm có viền', (tester) async {
      await _pump(tester);

      final boxes = tester.widgetList<IconButtonBox>(
        find.byType(IconButtonBox),
      );
      final back = boxes.firstWhere((b) => b.label == 'Quay lại');
      final search = boxes.firstWhere((b) => b.label == 'Tìm kiếm');
      expect(back.ghost, isTrue);
      expect(search.ghost, isFalse);
    });

    testWidgets('nút quay lại có nối hành động', (tester) async {
      await _pump(tester);
      final back = tester.widget<IconButtonBox>(
        find.byWidgetPredicate(
          (w) => w is IconButtonBox && w.label == 'Quay lại',
        ),
      );
      expect(back.onTap, isNotNull);
    });
  });

  group('MÀN 10 — quy ước màu', () {
    testWidgets('thẻ "File đang chọn" không phải tiền, dùng Card', (
      tester,
    ) async {
      await _pump(tester);
      // Ngoại lệ đã chốt: MÀN 10 không dùng SlipCard dù bản phác thảo vẽ
      // `.slip` cho khối này.
      expect(find.byType(SlipCard), findsNothing);
      expect(find.byType(Card), findsWidgets);
    });
  });

  group('MÀN 10 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Bằng chứng bàn giao',
        '14 file · dự án Minh An',
        'Lưới',
        'Dòng thời gian',
        // SectionLabel tự in hoa — ba dòng dưới đây hiển thị viết hoa dù
        // chuỗi gốc trong `_Demo` viết thường.
        'HÔM NAY · 25/07',
        'logo_v2.png',
        'zalo_gui.jpg',
        'guideline.pdf',
        '4.2 MB',
        '21/07 · ĐỢT NHÁP 1',
        '+9',
        'FILE ĐANG CHỌN',
        'Đã ghi nhận',
        '2.1 MB · tải lên 09:12 · bởi bạn',
        'Gắn vào task',
        'Tạo link 7 ngày',
        'Dung lượng gói Solo Pro',
        '1,8 / 10 GB',
        'Chụp hoặc chọn file',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });
  });

  group('MÀN 10 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 10 kho bằng chứng bàn giao', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(EvidencePage),
      matchesGoldenFile('goldens/screen_10_evidence.png'),
    );
  }, skip: !soloFontsLoaded);
}
