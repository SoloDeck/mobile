/// Kênh gửi nhắc nhở. Mirrors giá trị backend cho trường `channel`.
enum ReminderChannel { email, inApp, both, zalo }

extension ReminderChannelX on ReminderChannel {
  /// Giá trị backend mong đợi — xem cảnh báo lỗi 500 ở
  /// [ReminderTargetTypeX.wireValue], áp dụng y hệt cho enum này.
  String get wireValue => switch (this) {
    ReminderChannel.email => 'email',
    ReminderChannel.inApp => 'in_app',
    ReminderChannel.both => 'both',
    ReminderChannel.zalo => 'zalo',
  };

  String get label => switch (this) {
    ReminderChannel.email => 'Email dự phòng',
    ReminderChannel.inApp => 'Trong ứng dụng',
    ReminderChannel.both => 'Cả hai',
    ReminderChannel.zalo => 'Zalo OA',
  };
}

ReminderChannel reminderChannelFromWire(String value) => switch (value) {
  'email' => ReminderChannel.email,
  'in_app' => ReminderChannel.inApp,
  'both' => ReminderChannel.both,
  'zalo' => ReminderChannel.zalo,
  _ => throw ArgumentError.value(value, 'value', 'Unknown reminder channel'),
};
