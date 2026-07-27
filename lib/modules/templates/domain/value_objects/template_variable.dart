final RegExp _variablePattern = RegExp(r'\{\{(\w+)\}\}');

/// Trích danh sách tên biến từ các token dạng `{{ten_bien}}` trong [body] —
/// quy ước biến của mẫu tài liệu: đặt tên biến trong cặp ngoặc nhọn kép, ví
/// dụ `{{client_name}}`. Giữ thứ tự xuất hiện lần đầu, khử trùng lặp.
List<String> extractTemplateVariables(String body) {
  final seen = <String>{};
  final variables = <String>[];
  for (final match in _variablePattern.allMatches(body)) {
    final name = match.group(1)!;
    if (seen.add(name)) {
      variables.add(name);
    }
  }
  return variables;
}
