/// Điều khoản còn thiếu khi kiểm mẫu đang mở. Cảnh báo chỉ mang tính nhắc
/// nhở — tài liệu đã gửi trước đây giữ nguyên bản chụp, không bị sửa ngược
/// khi mẫu thay đổi.
enum TemplateLintIssue {
  missingCopyright,
  missingPaymentTerms,
  missingRevisionRounds,
}

extension TemplateLintIssueX on TemplateLintIssue {
  String get message => switch (this) {
    TemplateLintIssue.missingCopyright =>
      'Mẫu này thiếu điều khoản bản quyền. Tài liệu đã gửi trước đây không '
          'thay đổi.',
    TemplateLintIssue.missingPaymentTerms =>
      'Mẫu này thiếu điều khoản thanh toán. Tài liệu đã gửi trước đây không '
          'thay đổi.',
    TemplateLintIssue.missingRevisionRounds =>
      'Mẫu này thiếu điều khoản số vòng sửa. Tài liệu đã gửi trước đây không '
          'thay đổi.',
  };
}

/// Kiểm tra nhanh nội dung mẫu, không phân biệt hoa/thường, để nhắc các điều
/// khoản thường bị bỏ sót.
class TemplateLint {
  const TemplateLint._();

  static List<TemplateLintIssue> check(String body) {
    final lower = body.toLowerCase();
    final issues = <TemplateLintIssue>[];
    if (!lower.contains('bản quyền')) {
      issues.add(TemplateLintIssue.missingCopyright);
    }
    if (!lower.contains('thanh toán')) {
      issues.add(TemplateLintIssue.missingPaymentTerms);
    }
    // Bắt được cả "Sửa đổi", "vòng sửa", "chỉnh sửa" — mọi cách viết đều
    // chứa chuỗi con "sửa".
    if (!lower.contains('sửa')) {
      issues.add(TemplateLintIssue.missingRevisionRounds);
    }
    return issues;
  }
}
