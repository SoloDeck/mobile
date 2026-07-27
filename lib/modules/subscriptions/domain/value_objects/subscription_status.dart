import 'package:freezed_annotation/freezed_annotation.dart';

/// Trạng thái của gói đăng ký hiện tại. Mirrors the backend `SubscriptionStatus`
/// enum.
enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('past_due')
  pastDue,
  @JsonValue('suspended')
  suspended,
  @JsonValue('cancelled')
  cancelled,
}

extension SubscriptionStatusX on SubscriptionStatus {
  /// Snake-case value the backend expects (matches the `@JsonValue` strings).
  String get wireValue => switch (this) {
    SubscriptionStatus.active => 'active',
    SubscriptionStatus.pastDue => 'past_due',
    SubscriptionStatus.suspended => 'suspended',
    SubscriptionStatus.cancelled => 'cancelled',
  };

  String get label => switch (this) {
    SubscriptionStatus.active => 'Đang hoạt động',
    SubscriptionStatus.pastDue => 'Quá hạn thanh toán',
    SubscriptionStatus.suspended => 'Đã tạm ngưng',
    SubscriptionStatus.cancelled => 'Đã huỷ',
  };
}

SubscriptionStatus subscriptionStatusFromWire(String value) => switch (value) {
  'active' => SubscriptionStatus.active,
  'past_due' => SubscriptionStatus.pastDue,
  'suspended' => SubscriptionStatus.suspended,
  'cancelled' => SubscriptionStatus.cancelled,
  _ => throw ArgumentError.value(value, 'value', 'Unknown subscription status'),
};
