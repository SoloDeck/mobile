import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_lint.dart';

/// Kiểm tra nhanh nội dung mẫu — hàm thuần, không cần repository vì
/// `TemplateLint.check` chỉ đọc trực tiếp trên chuỗi `body` đang soạn/xem,
/// không đụng đến kho lưu trữ.
class LintTemplateUseCase {
  const LintTemplateUseCase();

  List<TemplateLintIssue> call(String body) => TemplateLint.check(body);
}
