import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';

/// Soạn nội dung nhắc — hàm THUẦN, chạy hoàn toàn offline, không gọi API,
/// không phụ thuộc AI thật (đây là bản soạn sẵn phía client để người dùng
/// XEM VÀ SỬA trước khi gửi — không vi phạm quy tắc "AI không tự gửi" vì kết
/// quả chỉ nằm trong ô soạn thảo, không có đường nào từ đây thẳng tới API).
class ReminderMessageComposer {
  const ReminderMessageComposer._();

  static String compose({
    required ReminderTone tone,
    required String clientName,
    required double amount,
    required DateTime dueDate,
    required bool attachPaymentLink,
  }) {
    final amountText = _formatVnd(amount);
    final dateText = _fmtDate(dueDate);
    final greeting = 'Dạ chào $clientName';
    final body = switch (tone) {
      ReminderTone.friendly =>
        '$greeting, mình nhắc nhẹ khoản trị giá $amountText đến hạn ngày $dateText nha. '
            'Bạn xuất hoá đơn hay lùi lịch thì báo mình nhé!',
      ReminderTone.polite =>
        '$greeting, em gửi anh/chị nhắc về khoản thanh toán trị giá $amountText, '
            'đến hạn ngày $dateText ạ. Nếu cần em xuất hoá đơn hay lùi lịch thì anh/chị nhắn em nhé. Em cảm ơn.',
      ReminderTone.firm =>
        '$greeting, khoản trị giá $amountText đã đến hạn ngày $dateText. '
            'Đề nghị anh/chị xuất hoá đơn hay lùi lịch trong hôm nay để tránh gián đoạn dịch vụ.',
    };
    if (!attachPaymentLink) return body;
    return '$body\n\nEm có tạo sẵn link MoMo bên dưới để anh/chị thanh toán nhanh.';
  }

  /// Định dạng số tiền theo cách viết của người Việt: chấm ngăn nghìn, ký
  /// hiệu ₫ đứng sau, cách một khoảng trắng — cùng thuật toán với
  /// `Money.format` của `lib/ui/money.dart` nhưng viết độc lập vì domain
  /// không được import Flutter/lib/ui.
  static String _formatVnd(double amount) {
    final rounded = amount.round();
    final digits = rounded.abs().toString();
    final grouped = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('.');
      grouped.write(digits[i]);
    }

    return '${rounded < 0 ? '-' : ''}$grouped ₫';
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
