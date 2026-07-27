import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_variable.dart';

Template _template({
  String id = 'tpl-1',
  String name = 'Mẫu test',
  TemplateCategory category = TemplateCategory.contract,
  required String body,
}) => Template(
  id: id,
  name: name,
  category: category,
  body: body,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  group('extractTemplateVariables', () {
    test('body rỗng trả về danh sách rỗng', () {
      expect(extractTemplateVariables(''), isEmpty);
    });

    test('body không có biến trả về danh sách rỗng', () {
      expect(
        extractTemplateVariables('Không có biến nào trong đoạn văn này.'),
        isEmpty,
      );
    });

    test('body có biến lặp lại thì khử trùng, giữ thứ tự lần đầu', () {
      expect(extractTemplateVariables('{{a}} {{b}} {{a}}'), ['a', 'b']);
    });

    test('body có 11 biến phân biệt trả về đủ 11 phần tử', () {
      final body = List.generate(11, (i) => '{{var_$i}}').join(' ');
      final result = extractTemplateVariables(body);
      expect(result, hasLength(11));
      expect(result, List.generate(11, (i) => 'var_$i'));
    });
  });

  group('Template.docTitle', () {
    test('lấy dòng đầu tiên của đoạn văn đầu tiên', () {
      final template = _template(body: 'Tiêu đề\nDòng phụ\n\nĐoạn 2');
      expect(template.docTitle, 'Tiêu đề');
    });

    test('body không có đoạn trống kép -> dòng đầu tiên của toàn bộ body', () {
      final template = _template(body: 'Chỉ một dòng duy nhất');
      expect(template.docTitle, 'Chỉ một dòng duy nhất');
    });

    test('body rỗng -> trả về tên mẫu làm dự phòng', () {
      final template = _template(name: 'Tên dự phòng', body: '');
      expect(template.docTitle, 'Tên dự phòng');
    });
  });

  group('Template.previewExcerpt', () {
    // Body dùng làm golden test đối chiếu MÀN 14 — giữ nguyên văn, không
    // chỉnh sửa khoảng trắng/ký tự đặc biệt.
    const contractBody =
        'HỢP ĐỒNG DỊCH VỤ\n'
        'Tham chiếu: {{client_name}} · {{price}}\n'
        '\n'
        'Điều 1. Thông tin các bên\n'
        '{{freelancer_name}} và {{client_name}} thống nhất…\n'
        '\n'
        'Điều 2. Phạm vi công việc\n'
        '{{scope}}';

    test('tách đúng before/firstVariable/between/secondVariable/after', () {
      final template = _template(body: contractBody);
      final excerpt = template.previewExcerpt;

      expect(excerpt, isNotNull);
      expect(excerpt!.before, 'Điều 1. Thông tin các bên\n');
      expect(excerpt.firstVariable, 'freelancer_name');
      expect(excerpt.between, ' và ');
      expect(excerpt.secondVariable, 'client_name');
      expect(excerpt.after, ' thống nhất…');
    });

    test('variables giữ đúng thứ tự xuất hiện lần đầu, khử trùng', () {
      final template = _template(body: contractBody);
      expect(template.variables, [
        'client_name',
        'price',
        'freelancer_name',
        'scope',
      ]);
    });

    test('body chỉ có 1 đoạn -> previewExcerpt là null', () {
      final template = _template(body: 'Chỉ một đoạn văn duy nhất.');
      expect(template.previewExcerpt, isNull);
    });

    test('đoạn thứ hai chỉ có 1 biến -> previewExcerpt là null', () {
      final template = _template(
        body: 'Đoạn đầu tiên.\n\nĐoạn hai chỉ có {{one_var}} và hết.',
      );
      expect(template.previewExcerpt, isNull);
    });
  });
}
