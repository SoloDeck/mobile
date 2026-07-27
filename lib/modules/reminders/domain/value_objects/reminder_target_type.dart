/// Loại đối tượng mà một nhắc nhở nhắm tới. Mirrors DB enum
/// `reminder_target_type` phía backend — CHỈ có bốn giá trị này, TUYỆT ĐỐI
/// không có `proposal` (dù docstring API cũ ghi nhầm).
enum ReminderTargetType { deal, client, invoice, contract }

extension ReminderTargetTypeX on ReminderTargetType {
  /// Giá trị backend mong đợi. Backend không validate enum ở tầng Pydantic —
  /// gửi sai giá trị sẽ ra lỗi 500 chứ không phải 422 — nên đây PHẢI là nguồn
  /// wire value duy nhất trong toàn bộ luồng.
  String get wireValue => switch (this) {
    ReminderTargetType.deal => 'deal',
    ReminderTargetType.client => 'client',
    ReminderTargetType.invoice => 'invoice',
    ReminderTargetType.contract => 'contract',
  };

  String get label => switch (this) {
    ReminderTargetType.deal => 'Thương vụ',
    ReminderTargetType.client => 'Khách hàng',
    ReminderTargetType.invoice => 'Hoá đơn',
    ReminderTargetType.contract => 'Hợp đồng',
  };
}

ReminderTargetType reminderTargetTypeFromWire(String value) => switch (value) {
  'deal' => ReminderTargetType.deal,
  'client' => ReminderTargetType.client,
  'invoice' => ReminderTargetType.invoice,
  'contract' => ReminderTargetType.contract,
  _ => throw ArgumentError.value(
    value,
    'value',
    'Unknown reminder target type',
  ),
};
