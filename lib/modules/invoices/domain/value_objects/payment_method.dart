import 'package:freezed_annotation/freezed_annotation.dart';

/// How a payment was received (phương thức thanh toán). Mirrors the backend
/// `PaymentMethod` enum.
enum PaymentMethod {
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('cash')
  cash,
  @JsonValue('online')
  online,
  @JsonValue('other')
  other,
}

extension PaymentMethodX on PaymentMethod {
  /// Snake-case value the backend expects (matches the `@JsonValue` strings).
  String get wireValue => switch (this) {
    PaymentMethod.bankTransfer => 'bank_transfer',
    PaymentMethod.cash => 'cash',
    PaymentMethod.online => 'online',
    PaymentMethod.other => 'other',
  };

  String get label => switch (this) {
    PaymentMethod.bankTransfer => 'Chuyển khoản',
    PaymentMethod.cash => 'Tiền mặt',
    PaymentMethod.online => 'Thanh toán online',
    PaymentMethod.other => 'Khác',
  };
}
