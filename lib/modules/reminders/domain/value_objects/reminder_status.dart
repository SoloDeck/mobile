/// Trạng thái vòng đời của một nhắc nhở. Mirrors giá trị backend cho trường
/// `status`. Backend luôn ép `status='pending'` khi tạo mới — không có
/// endpoint "gửi ngay" đồng bộ, việc gửi thật do worker Celery nền xử lý sau.
enum ReminderStatus { pending, sent, failed, cancelled, skipped }

extension ReminderStatusX on ReminderStatus {
  /// Giá trị backend mong đợi — xem cảnh báo lỗi 500 ở
  /// [ReminderTargetTypeX.wireValue], áp dụng y hệt cho enum này.
  String get wireValue => switch (this) {
    ReminderStatus.pending => 'pending',
    ReminderStatus.sent => 'sent',
    ReminderStatus.failed => 'failed',
    ReminderStatus.cancelled => 'cancelled',
    ReminderStatus.skipped => 'skipped',
  };

  String get label => switch (this) {
    ReminderStatus.pending => 'Đang chờ gửi',
    ReminderStatus.sent => 'Đã gửi',
    ReminderStatus.failed => 'Gửi thất bại',
    ReminderStatus.cancelled => 'Đã huỷ',
    ReminderStatus.skipped => 'Đã bỏ qua',
  };
}

ReminderStatus reminderStatusFromWire(String value) => switch (value) {
  'pending' => ReminderStatus.pending,
  'sent' => ReminderStatus.sent,
  'failed' => ReminderStatus.failed,
  'cancelled' => ReminderStatus.cancelled,
  'skipped' => ReminderStatus.skipped,
  _ => throw ArgumentError.value(value, 'value', 'Unknown reminder status'),
};
