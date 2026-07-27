/// Kịch bản nội dung của một nhắc nhở. Mirrors giá trị backend cho trường
/// `reminder_type`.
enum ReminderType {
  followUp,
  proposalFollowUp,
  contractSigningNudge,
  paymentDue,
  paymentOverdue,
  reEngagement,
}

extension ReminderTypeX on ReminderType {
  /// Giá trị backend mong đợi — xem cảnh báo lỗi 500 ở
  /// [ReminderTargetTypeX.wireValue], áp dụng y hệt cho enum này.
  String get wireValue => switch (this) {
    ReminderType.followUp => 'follow_up',
    ReminderType.proposalFollowUp => 'proposal_follow_up',
    ReminderType.contractSigningNudge => 'contract_signing_nudge',
    ReminderType.paymentDue => 'payment_due',
    ReminderType.paymentOverdue => 'payment_overdue',
    ReminderType.reEngagement => 're_engagement',
  };

  String get label => switch (this) {
    ReminderType.followUp => 'Theo dõi tiếp',
    ReminderType.proposalFollowUp => 'Nhắc duyệt báo giá',
    ReminderType.contractSigningNudge => 'Nhắc ký hợp đồng',
    ReminderType.paymentDue => 'Sắp đến hạn',
    ReminderType.paymentOverdue => 'Quá hạn thanh toán',
    ReminderType.reEngagement => 'Kết nối lại',
  };
}

ReminderType reminderTypeFromWire(String value) => switch (value) {
  'follow_up' => ReminderType.followUp,
  'proposal_follow_up' => ReminderType.proposalFollowUp,
  'contract_signing_nudge' => ReminderType.contractSigningNudge,
  'payment_due' => ReminderType.paymentDue,
  'payment_overdue' => ReminderType.paymentOverdue,
  're_engagement' => ReminderType.reEngagement,
  _ => throw ArgumentError.value(value, 'value', 'Unknown reminder type'),
};
