/// Giọng văn khi soạn nhắc — CHỈ tồn tại phía client, KHÔNG có wireValue,
/// KHÔNG bao giờ gửi lên backend (backend không có khái niệm này).
///
/// Ba mức chứ không phải hai "trang trọng / thân mật" thông thường, vì đòi nợ
/// lần bảy khác hẳn lần đầu.
enum ReminderTone { friendly, polite, firm }

extension ReminderToneX on ReminderTone {
  String get label => switch (this) {
    ReminderTone.friendly => 'Thân mật',
    ReminderTone.polite => 'Lịch sự',
    ReminderTone.firm => 'Dứt khoát',
  };
}
