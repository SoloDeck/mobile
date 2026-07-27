import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_lint.dart';

void main() {
  group('TemplateLint.check', () {
    test('thiếu cả 3 điều khoản -> trả về đủ 3 issue đúng thứ tự', () {
      final issues = TemplateLint.check('Nội dung không có gì đặc biệt cả.');

      expect(issues, [
        TemplateLintIssue.missingCopyright,
        TemplateLintIssue.missingPaymentTerms,
        TemplateLintIssue.missingRevisionRounds,
      ]);
    });

    test('có đủ cả 3 cụm (không phân biệt hoa/thường) -> trả về rỗng', () {
      final issues = TemplateLint.check(
        'Bản Quyền thuộc về bên cung cấp dịch vụ. '
        'Điều khoản THANH TOÁN được quy định rõ ràng. '
        'Cho phép sửa đổi tối đa 2 lần.',
      );

      expect(issues, isEmpty);
    });

    test('thiếu đúng 1 cụm (bản quyền) -> chỉ trả về issue tương ứng', () {
      final issues = TemplateLint.check(
        'Điều khoản thanh toán được quy định rõ ràng. '
        'Cho phép sửa tối đa 2 lần.',
      );

      expect(issues, [TemplateLintIssue.missingCopyright]);
    });

    test('nguyên văn message của missingCopyright', () {
      expect(
        TemplateLintIssue.missingCopyright.message,
        'Mẫu này thiếu điều khoản bản quyền. Tài liệu đã gửi trước đây không '
        'thay đổi.',
      );
    });
  });
}
