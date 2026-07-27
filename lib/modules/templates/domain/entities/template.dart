import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_variable.dart';

part 'template.freezed.dart';

/// Một mẫu tài liệu (báo giá/hợp đồng/hoá đơn) trong thư viện tự quản.
/// Local-first bằng Drift — backend không có API cho mẫu của người dùng.
@freezed
abstract class Template with _$Template {
  const factory Template({
    required String id,
    required String name,
    required TemplateCategory category,
    required String body,
    @Default(false) bool isSystem,
    @Default(false) bool isDefault,
    String? sourceTemplateId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Template;
}

/// Đoạn xem trước đã tách quanh hai biến `{{...}}` đầu tiên, để trang hiển
/// thị ghép lại thành `Text.rich` (văn bản thường xen chip biến).
class TemplatePreviewExcerpt {
  const TemplatePreviewExcerpt({
    required this.before,
    required this.firstVariable,
    required this.between,
    required this.secondVariable,
    required this.after,
  });

  final String before;
  final String firstVariable;
  final String between;
  final String secondVariable;
  final String after;
}

extension TemplateX on Template {
  /// Danh sách biến `{{...}}` xuất hiện trong [body], khử trùng, giữ thứ tự.
  List<String> get variables => extractTemplateVariables(body);

  /// Tiêu đề tài liệu — dòng đầu tiên của đoạn văn đầu tiên trong [body]
  /// (đoạn = tách theo dòng trống kép `\n\n`).
  String get docTitle {
    final paragraphs = body.split('\n\n');
    if (paragraphs.isEmpty) return name;
    final firstLine = paragraphs.first.split('\n').first.trim();
    return firstLine.isEmpty ? name : firstLine;
  }

  /// Đoạn xem trước để hiện trong thẻ "xem trước": lấy đoạn văn thứ hai của
  /// [body], rồi tách quanh hai biến `{{...}}` đầu tiên xuất hiện trong đoạn
  /// đó. Trả về `null` nếu không đủ hai đoạn hoặc đoạn thứ hai không có đủ
  /// hai biến — trang hiển thị phải ẩn thẻ xem trước khi gặp `null`, không
  /// được ném lỗi.
  TemplatePreviewExcerpt? get previewExcerpt {
    final paragraphs = body.split('\n\n');
    if (paragraphs.length < 2) return null;
    final para = paragraphs[1];
    final matches = RegExp(r'\{\{(\w+)\}\}').allMatches(para).toList();
    if (matches.length < 2) return null;
    final m1 = matches[0];
    final m2 = matches[1];
    return TemplatePreviewExcerpt(
      before: para.substring(0, m1.start),
      firstVariable: m1.group(1)!,
      between: para.substring(m1.end, m2.start),
      secondVariable: m2.group(1)!,
      after: para.substring(m2.end),
    );
  }
}
