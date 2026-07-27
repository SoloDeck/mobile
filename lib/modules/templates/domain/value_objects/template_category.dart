/// Loại tài liệu của một mẫu. Không có DTO/JSON cho templates (thư viện tự
/// quản, local-first) nên không cần `@JsonValue` — [wireValue] chỉ dùng để
/// lưu cột `category` trong bảng Drift.
enum TemplateCategory { proposal, contract, invoice }

extension TemplateCategoryX on TemplateCategory {
  /// Giá trị lưu trong cột `category` của Drift.
  String get wireValue => switch (this) {
    TemplateCategory.proposal => 'proposal',
    TemplateCategory.contract => 'contract',
    TemplateCategory.invoice => 'invoice',
  };

  String get label => switch (this) {
    TemplateCategory.proposal => 'Báo giá',
    TemplateCategory.contract => 'Hợp đồng',
    TemplateCategory.invoice => 'Hoá đơn',
  };
}

TemplateCategory templateCategoryFromWire(String value) => switch (value) {
  'proposal' => TemplateCategory.proposal,
  'contract' => TemplateCategory.contract,
  'invoice' => TemplateCategory.invoice,
  _ => throw ArgumentError.value(value, 'value', 'Unknown template category'),
};
