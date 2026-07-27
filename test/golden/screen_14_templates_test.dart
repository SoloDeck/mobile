import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/repository/templates_repository_impl.dart';
import 'package:solodesk_mobile/modules/templates/presentation/pages/templates_page.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/notice_card.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';

/// Trả về danh sách mẫu CỐ ĐỊNH truyền vào constructor — golden test này chỉ
/// đọc (không có bài nào bấm nút "Chép"), nên `copyTemplate`/
/// `setDefaultTemplate`/`deleteTemplate` không cần triển khai thật.
class _FakeTemplatesRepository implements TemplatesRepository {
  const _FakeTemplatesRepository(this.templates);

  final List<Template> templates;

  @override
  Future<List<Template>> listTemplates({TemplateCategory? category}) async =>
      templates;

  @override
  Future<Template?> getTemplate(String id) => throw UnimplementedError();

  @override
  Future<Template> copyTemplate(String sourceId) => throw UnimplementedError();

  @override
  Future<void> setDefaultTemplate(String id) => throw UnimplementedError();

  @override
  Future<void> deleteTemplate(String id) => throw UnimplementedError();
}

/// Mẫu của tôi, đang là mặc định. `updatedAt` đúng 3 ngày trước mốc
/// [appClockProvider] giả lập ở `_pump` (2026-07-25) để khớp chuỗi "sửa 3
/// ngày trước". Nội dung cố ý KHÔNG chứa "bản quyền" — kích hoạt đúng một
/// lỗi lint (`missingCopyright`) — nhưng CÓ chứa "thanh toán" (Điều 4) và
/// "sửa" (Điều 6) nên hai lỗi lint còn lại không bật.
///
/// Không phải `const`: `DateTime(...)` không có hằng constructor trong Dart,
/// nên `Template` (dù `@freezed`) cũng không thể dựng làm hằng số ở đây.
final tDefault = Template(
  id: 't-default',
  name: 'Hợp đồng thiết kế nhận diện',
  category: TemplateCategory.contract,
  isSystem: false,
  isDefault: true,
  sourceTemplateId: null,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 7, 22),
  body: '''HỢP ĐỒNG DỊCH VỤ
Tham chiếu: {{client_name}} · {{price}}

Điều 1. Thông tin các bên
{{freelancer_name}} và {{client_name}} thống nhất…

Điều 2. Phạm vi công việc
{{scope}}

Điều 3. Tiến độ thực hiện
{{timeline}}

Điều 4. Điều khoản thanh toán
{{payment_terms}}

Điều 5. Bảo mật thông tin
{{confidentiality}}

Điều 6. Sửa đổi và bổ sung
{{revision_terms}}

Điều 7. Chấm dứt hợp đồng
{{termination_terms}}

Điều 8. Luật áp dụng
{{governing_law}}

Điều 9. Hiệu lực
{{effective_date}}''',
);

/// Mẫu tự tạo, chép từ mẫu hệ thống rồi sửa lại — `sourceTemplateId` trỏ về
/// [tSystem]. Nội dung tuỳ ý, không có assert nào soi vào `body`.
final tCopied = Template(
  id: 't-copied',
  name: 'Báo giá gấp — khách quen',
  category: TemplateCategory.proposal,
  isSystem: false,
  isDefault: false,
  sourceTemplateId: 'sys-proposal-standard',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: null,
  body: 'Báo giá nhanh cho {{client_name}}, chi phí {{price}}.',
);

/// Mẫu hệ thống, chỉ đọc. Nội dung tuỳ ý, không có assert nào soi vào `body`.
final tSystem = Template(
  id: 'sys-proposal-standard',
  name: 'Báo giá dịch vụ tiêu chuẩn',
  category: TemplateCategory.proposal,
  isSystem: true,
  isDefault: false,
  sourceTemplateId: null,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: null,
  body: 'Báo giá tiêu chuẩn cho {{client_name}}.',
);

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        templatesRepositoryProvider.overrideWithValue(
          _FakeTemplatesRepository([tDefault, tCopied, tSystem]),
        ),
        appClockProvider.overrideWithValue(() => DateTime(2026, 7, 25)),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TemplatesPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 14 — cấu trúc theo figcaption', () {
    testWidgets('mẫu hệ thống và mẫu tự tạo nằm chung một danh sách Card', (
      tester,
    ) async {
      await _pump(tester);

      // Ba thẻ mẫu + một thẻ xem trước = 4 Card, không tách tab riêng.
      expect(find.byType(Card), findsNWidgets(4));
    });

    testWidgets(
      'mẫu hệ thống có nhãn "chỉ đọc" trong phụ đề, và nút "Chép" thật',
      (tester) async {
        await _pump(tester);

        expect(find.textContaining('chỉ đọc'), findsOneWidget);
        expect(find.text('Chép'), findsOneWidget);

        final copyButton = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.button == true,
        );
        expect(copyButton, findsWidgets);
      },
    );

    testWidgets('biến {{...}} dùng chip tím mono, "+9" thì không', (
      tester,
    ) async {
      await _pump(tester);

      final aiMonoLabels = tester
          .widgetList<StatusChip>(find.byType(StatusChip))
          .where((chip) => chip.tone == Tone.ai && chip.mono)
          .map((chip) => chip.label)
          .toList();

      expect(
        aiMonoLabels,
        containsAll(<String>['{{client_name}}', '{{price}}']),
      );

      final plusNineChip = tester.widget<StatusChip>(
        find.widgetWithText(StatusChip, '+9'),
      );
      expect(plusNineChip.tone, isNot(Tone.ai));
    });

    testWidgets('cảnh báo thiếu điều khoản nói rõ tài liệu cũ không đổi', (
      tester,
    ) async {
      await _pump(tester);

      final notice = tester.widget<NoticeCard>(find.byType(NoticeCard));
      expect(notice.tone, Tone.warn);
      expect(notice.message, contains('không'));
      expect(notice.message, contains('thay đổi'));
    });

    testWidgets('không có ô soạn thảo hay nút "Soạn thảo" nào', (tester) async {
      await _pump(tester);

      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.textContaining('Soạn thảo'), findsNothing);
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

  group('MÀN 14 — quy ước màu', () {
    testWidgets('mẫu của tôi (đang mặc định) avatar tím AI', (tester) async {
      await _pump(tester);

      final avatars = tester.widgetList<Avatar>(find.byType(Avatar)).toList();
      expect(avatars[0].tone, Tone.ai);
      expect(avatars[1].tone, Tone.money);
      expect(avatars[2].tone, Tone.neutral);
    });

    testWidgets('không có tấm phiếu răng cưa nào — màn này không có tiền', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SlipCard), findsNothing);
    });
  });

  group('MÀN 14 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Mẫu của tôi',
        'Tất cả · 3',
        'Báo giá',
        'Hợp đồng',
        'Hoá đơn',
        'Hợp đồng thiết kế nhận diện',
        'Của tôi · sửa 3 ngày trước',
        'Mặc định',
        '{{client_name}}',
        '{{price}}',
        '+9',
        'Báo giá gấp — khách quen',
        'Chép từ mẫu hệ thống · đã sửa',
        'Báo giá dịch vụ tiêu chuẩn',
        'Mẫu hệ thống · chỉ đọc',
        'Chép',
        // `SectionLabel`/`SectionHeader` tự in hoa, giống `.lbl` của CSS
        // (`text-transform: uppercase`) — kiểm bản đã in hoa, không phải
        // chuỗi gốc trong `_MockData`.
        'KIỂM TRA MẪU ĐANG MỞ',
        'Mẫu này thiếu điều khoản bản quyền. Tài liệu đã gửi trước đây không '
            'thay đổi.',
        'XEM TRƯỚC',
        'HỢP ĐỒNG DỊCH VỤ',
        '{{freelancer_name}}',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }

      // Đoạn văn xem trước ghép từ nhiều TextSpan/WidgetSpan, kiểm bằng
      // textContaining trên toàn bộ RichText thay vì find.text.
      expect(
        find.textContaining('Điều 1. Thông tin các bên', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('thống nhất…', findRichText: true),
        findsOneWidget,
      );
    });
  });

  group('MÀN 14 — quy tắc không được vi phạm', () {
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

  testWidgets('ảnh vàng — màn 14 thư viện mẫu tự quản', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(TemplatesPage),
      matchesGoldenFile('goldens/screen_14_templates.png'),
    );
  }, skip: !soloFontsLoaded);
}
